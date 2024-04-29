--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PRICE_PVT" AS
/* $Header: OEXVOPRB.pls 120.26.12010000.10 2010/04/16 04:40:23 ramising ship $ */

G_DEBUG BOOLEAN;
--2649821 Changed G_ROUNDING_FLAG to Q
G_ROUNDING_FLAG VARCHAR2(1):= 'Q'; --nvl(Fnd_Profile.value('OE_UNIT_PRICE_ROUNDING'),'N');
G_SEEDED_GSA_HOLD_ID CONSTANT NUMBER:= 2;
G_CHARGES_FOR_INCLUDED_ITEM Varchar2(30)
      := nvl(fnd_profile.value('ONT_CHARGES_FOR_INCLUDED_ITEM'),'N');
G_PASS_ALL_LINES VARCHAR2(30);
--bug4080363 commented the following
-- bug 3491752
--G_LIST_PRICE_OVERRIDE Varchar2(30)
  --    := nvl(fnd_profile.value('ONT_LIST_PRICE_OVERRIDE_PRIV'), 'NONE');

g_request_id	number := null;
G_IPL_ERRORS_TBL OE_GLOBALS.Number_Tbl_Type;
-- G_BINARY_LIMIT CONSTANT NUMBER:=2147483647; -- Bug 8631297
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8631297

--rc
G_CHARGE_PERIODICITY_CODE_TBL              QP_PREQ_GRP.VARCHAR_3_TYPE;

--
G_ADDED_PARENT_TBL OE_GLOBALS.Number_Tbl_Type;

-- AG Changes
TYPE PLS_INTEGER_TYPE   IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
TYPE NUMBER_TYPE        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR_TYPE       IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE FLAG_TYPE          IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE ROWID_TYPE         IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE DATE_TYPE          IS TABLE OF DATE INDEX BY BINARY_INTEGER;
Type rounding_factor_rec is Record
(List_Header_id                 number
,rounding_factor        number
);
g_rounding_factor_rec rounding_factor_rec;
Type Index_Tbl_Type is table of number
        Index by Binary_Integer;

Type key_rec_type is record
(db_start NUMBER DEFAULT NULL,
 db_end   NUMBER DEFAULT NULL
);
Type key_tbl_type is table of key_rec_type index by binary_integer;
--3021992
TYPE g_lineid_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER ;
g_lineid_tbl g_lineid_tbl_type ;
--3021992 ends

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
 G_CONTRACT_START_DATE_TBL     QP_PREQ_GRP.DATE_TYPE;
 G_CONTRACT_END_DATE_TBL       QP_PREQ_GRP.DATE_TYPE;
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
G_LIST_PRICE_OVERRIDE_FLAG_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
G_LINE_UNIT_PRICE_TBL   QP_PREQ_GRP.NUMBER_TYPE;
G_IS_THERE_FREEZE_OVERRIDE  Boolean:=TRUE;

--RT{
G_PRICING_EVENT VARCHAR2(80);
--3289822{Changed the size from 10 to 240
G_RETROBILL_OPERATION VARCHAR2(240);
--3289822}
--RT}

Function get_version Return Varchar2 is
Begin

 Return('/* $Header: OEXVOPRB.pls 120.26.12010000.10 2010/04/16 04:40:23 ramising ship $ */');

End;

procedure Adj_Debug (p_text IN VARCHAR2, p_level IN NUMBER:=5) As
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  If G_DEBUG Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  P_TEXT , P_LEVEL ) ;
     END IF;
  End If;
End Adj_Debug;


Function Check_Freeze_Override(p_pricing_event in Varchar2) Return
Boolean Is

Cursor get_phases(l_event_code1 in Varchar2) Is
 Select e.Pricing_Phase_Id,
        nvl(p.user_freeze_override_flag,p.freeze_override_flag) pof
		   from qp_event_Phases e, qp_pricing_phases p
		   where e.pricing_phase_id = p.pricing_phase_id and
		   trunc(sysdate) between Trunc(nvl(start_date_active,sysdate)) and
			 trunc(nvl(End_Date_Active,sysdate))
                       and e.pricing_event_code IN
                    (SELECT decode(rownum
          ,1 ,substr(p_pricing_event,1,instr(l_event_code1,',',1,1)-1)
          ,2 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
             instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,3 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,4 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,5 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,6 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1)))
         FROM  qp_event_phases
         WHERE rownum < 7);
         --
         l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
         --
Begin

 For i in get_phases(p_pricing_event||',') Loop

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PRICING PHASE:'||I.PRICING_PHASE_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'FREEZE OVERRIDE-NEW:'||I.POF ) ;
  END IF;

  If (i.pof = 'Y' and i.pricing_phase_id <> 1) Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FREEZE OVERRIDE IS Y' ) ;
    END IF;
    Return True;
  End If;
 End Loop;

 Return False;
End;



Function Get_List_Lines (p_line_id Number) Return Varchar2 As
 Cursor list_lines_no is
 Select c.name,
        a.list_line_no
 From   qp_preq_ldets_tmp a,
        qp_preq_lines_tmp b,
        qp_list_headers_vl c
 Where  b.line_id = p_line_id
 And    b.line_index = a.line_index
 And    a.created_from_list_header_id = c.list_header_id
 And    a.automatic_flag = 'Y'
 And    a.pricing_status_code = 'N'
 And    b.process_status <> 'NOT_VALID'
 And    a.created_from_list_line_type <> 'PLL';

 l_list_line_nos Varchar2(2000):=null;
 l_separator Varchar2(1):='';
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
Begin
 For i in List_Lines_no Loop
   l_list_line_nos := i.name||':'||i.list_line_no||l_separator||l_list_line_nos;
   l_separator := ',';
 End Loop;
 Return l_list_line_nos;
End Get_List_Lines;


--  Function Query_Header

PROCEDURE Query_Header
(   p_header_id             IN  NUMBER,
    x_header_rec            IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS
     l_org_id                      NUMBER;
     l_x_header_rec_oper  VARCHAR2(30);
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
BEGIN

     l_org_id := OE_GLOBALS.G_ORG_ID;
     IF l_org_id IS NULL THEN
           OE_GLOBALS.Set_Context;
           l_org_id := OE_GLOBALS.G_ORG_ID;
        END IF;

     -- aksingh use global record if exists for header_id
     IF oe_order_cache.g_header_rec.header_id = p_header_id THEN
        l_x_header_rec_oper := x_header_rec.operation;
        x_header_rec := oe_order_cache.g_header_rec;
        x_header_rec.operation := l_x_header_rec_oper;
        return;
     END IF;

  IF (QP_UTIL.GET_QP_STATUS = 'I') THEN
    OE_Header_UTIL.query_row(p_header_id=>p_header_id
                     ,   x_header_rec => x_header_rec
                   );

    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUERYING HEADER'||P_HEADER_ID , 3 ) ;
  END IF;
    SELECT  AGREEMENT_ID
         ,  CUST_PO_NUMBER
         ,  FREIGHT_TERMS_CODE
         ,  HEADER_ID
         ,  INVOICE_TO_ORG_ID
         ,  ORDER_CATEGORY_CODE
         ,  ORDER_TYPE_ID
         ,  ORDERED_DATE
         ,  PAYMENT_TERM_ID
         ,  PAYMENT_TYPE_CODE
         ,  PRICE_LIST_ID
         ,  PRICE_REQUEST_CODE
         ,  PRICING_DATE
         ,  REQUEST_DATE
         ,  SHIP_FROM_ORG_ID
         ,  SHIP_TO_ORG_ID
         ,  SHIPMENT_PRIORITY_CODE
         ,  SHIPPING_METHOD_CODE
         ,  SOLD_TO_ORG_ID
         ,  TRANSACTIONAL_CURR_CODE
         ,  LOCK_CONTROL
     INTO   x_header_rec.AGREEMENT_ID
         ,  x_header_rec.CUST_PO_NUMBER
         ,  x_header_rec.FREIGHT_TERMS_CODE
         ,  x_header_rec.HEADER_ID
         ,  x_header_rec.INVOICE_TO_ORG_ID
         ,  x_header_rec.ORDER_CATEGORY_CODE
         ,  x_header_rec.ORDER_TYPE_ID
         ,  x_header_rec.ORDERED_DATE
         ,  x_header_rec.PAYMENT_TERM_ID
         ,  x_header_rec.PAYMENT_TYPE_CODE
         ,  x_header_rec.PRICE_LIST_ID
         ,  x_header_rec.PRICE_REQUEST_CODE
         ,  x_header_rec.PRICING_DATE
         ,  x_header_rec.REQUEST_DATE
         ,  x_header_rec.SHIP_FROM_ORG_ID
         ,  x_header_rec.SHIP_TO_ORG_ID
         ,  x_header_rec.SHIPMENT_PRIORITY_CODE
         ,  x_header_rec.SHIPPING_METHOD_CODE
         ,  x_header_rec.SOLD_TO_ORG_ID
         ,  x_header_rec.TRANSACTIONAL_CURR_CODE
         ,  x_header_rec.LOCK_CONTROL
   FROM OE_ORDER_HEADERS_ALL
   WHERE HEADER_ID = p_header_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

           RAISE NO_DATA_FOUND;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Header;

PROCEDURE Query_Lines
(   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
 )
IS
l_org_id                        NUMBER;
l_count                         NUMBER;
l_entity                                VARCHAR2(1);
CURSOR l_line_csr IS
    SELECT  AGREEMENT_ID
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CUST_PO_NUMBER
    ,       COMMITMENT_ID
    ,       FREIGHT_TERMS_CODE
    ,        HEADER_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_TO_ORG_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ITEM_TYPE_CODE
    ,       ORDERED_ITEM_ID
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_TYPE_ID
    ,       ORDERED_QUANTITY
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY2 -- OPM 2434270
    ,       ORDERED_QUANTITY_UOM2  -- OPM 2434270
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE                --OPM 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROMISE_DATE
    ,       REQUEST_DATE
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPING_METHOD_CODE
    ,       SHIP_FROM_ORG_ID
    ,       SHIPPABLE_FLAG
    ,       SHIPPED_QUANTITY
    ,       SHIP_SET_ID
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       TAX_EXEMPT_FLAG
    ,       UNIT_LIST_PRICE
    ,       UNIT_LIST_PRICE_PER_PQTY
    ,       UNIT_SELLING_PRICE
    ,       UNIT_SELLING_PRICE_PER_PQTY
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       CALCULATE_PRICE_FLAG
    ,       upgraded_flag
    ,       CHARGE_PERIODICITY_CODE --rc
    ,       LOCK_CONTROL
    FROM    OE_ORDER_LINES  /* MOAC SQL NO CHANGE */
    WHERE   l_entity = 'L'
        -- AND ORDERED_QUANTITY <> 0 (--bug 3018537) commented for the FP bug 3335024
         AND   LINE_ID = p_line_id
UNION
    SELECT  AGREEMENT_ID
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CUST_PO_NUMBER
    ,       COMMITMENT_ID
    ,       FREIGHT_TERMS_CODE
    ,       HEADER_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_TO_ORG_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ITEM_TYPE_CODE
    ,       ORDERED_ITEM_ID
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_TYPE_ID
    ,       ORDERED_QUANTITY
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY2 -- OPM 2434270
    ,       ORDERED_QUANTITY_UOM2  -- OPM 2434270
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE                --OPM 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROMISE_DATE
    ,       REQUEST_DATE
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPING_METHOD_CODE
    ,       SHIP_FROM_ORG_ID
    ,       SHIPPABLE_FLAG
    ,       SHIPPED_QUANTITY
    ,       SHIP_SET_ID
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       TAX_EXEMPT_FLAG
    ,       UNIT_LIST_PRICE
    ,       UNIT_LIST_PRICE_PER_PQTY
    ,       UNIT_SELLING_PRICE
    ,       UNIT_SELLING_PRICE_PER_PQTY
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       CALCULATE_PRICE_FLAG
    ,       CHARGE_PERIODICITY_CODE --rc
    ,       upgraded_flag
    ,       LOCK_CONTROL
    FROM    OE_ORDER_LINES /* MOAC SQL NO CHANGE */
    WHERE   l_entity = 'H'
         --AND ORDERED_QUANTITY <> 0 (--bug 3018537) commented for the FP bug 3335024
         AND   HEADER_ID = p_header_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN QUERY LINES. GET_QP_STATUS:'||QP_UTIL.GET_QP_STATUS ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'G_RECURSION_MODE:'||OE_GLOBALS.G_RECURSION_MODE ) ;
END IF;
IF (QP_UTIL.GET_QP_STATUS = 'I' OR OE_GLOBALS.G_RECURSION_MODE <> FND_API.G_TRUE) THEN
  OE_LINE_UTIL.query_rows(p_line_id=>p_line_id
                     ,   p_header_id => p_header_id
                     ,   x_line_tbl => x_line_tbl
                   );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' X_LINE_TBL COUNT FROM OE_LINE_UTIL.QUERY_ROWS:'||X_LINE_TBL.COUNT ) ;
  END IF;
--commented for the FP bug 3335024
/*
 --bug 3289322, pl/sql error when count is zero
 if (x_line_tbl.count > 0) then
  --bug 3018537 begin
    for i in x_line_tbl.first..x_line_tbl.last loop
    if x_line_tbl(i).ordered_quantity = 0 then
    oe_debug_pub.add(' Not passing line id:'||x_line_tbl(i).line_id||' to pricing engine -- 0 ord qty ');
     x_line_tbl.delete(i);
    end if;
    end loop;
  oe_debug_pub.add(' New x_line_tbl count:'||x_line_tbl.count);
  end if;
  --bug 3018537 end
*/
  RETURN;
END IF;

    IF nvl(p_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

           l_entity := 'L';

    ELSIF nvl(p_header_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SETTING ENTITY TO H' ) ;
           END IF;
           l_entity := 'H';

    END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;
    if l_org_id IS NULL THEN
       OE_GLOBALS.Set_Context;
       l_org_id := OE_GLOBALS.G_ORG_ID;
    end if;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.QUERY_LINES '||TO_CHAR ( L_ORG_ID ) , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER_ID:'||P_HEADER_ID||' LINE_ID:'||P_LINE_ID , 3 ) ;
    END IF;


    --  Loop over fetched records

    l_count := 1;

    FOR l_implicit_rec IN l_line_csr LOOP

     x_line_tbl(l_count).AGREEMENT_ID        := l_implicit_rec.AGREEMENT_ID;
     x_line_tbl(l_count).CUST_PO_NUMBER      := l_implicit_rec.CUST_PO_NUMBER;
     x_line_tbl(l_count).FREIGHT_TERMS_CODE  := l_implicit_rec.FREIGHT_TERMS_CODE;
     x_line_tbl(l_count).HEADER_ID           := l_implicit_rec.HEADER_ID;
     x_line_tbl(l_count).INVENTORY_ITEM_ID   := l_implicit_rec.INVENTORY_ITEM_ID;
     x_line_tbl(l_count).INVOICE_TO_ORG_ID   := l_implicit_rec.INVOICE_TO_ORG_ID;
     x_line_tbl(l_count).ITEM_IDENTIFIER_TYPE:= l_implicit_rec.ITEM_IDENTIFIER_TYPE;
     x_line_tbl(l_count).ITEM_TYPE_CODE      := l_implicit_rec.ITEM_TYPE_CODE;
     x_line_tbl(l_count).ORDERED_ITEM_ID     := l_implicit_rec.ORDERED_ITEM_ID;
     x_line_tbl(l_count).LINE_CATEGORY_CODE  := l_implicit_rec.LINE_CATEGORY_CODE;
     x_line_tbl(l_count).LINE_ID             := l_implicit_rec.LINE_ID;
     x_line_tbl(l_count).LINE_TYPE_ID        := l_implicit_rec.LINE_TYPE_ID;
     x_line_tbl(l_count).ORDERED_QUANTITY    := l_implicit_rec.ORDERED_QUANTITY;
     x_line_tbl(l_count).ORDER_QUANTITY_UOM  := l_implicit_rec.ORDER_QUANTITY_UOM;
     x_line_tbl(l_count).ORDERED_QUANTITY2    := l_implicit_rec.ORDERED_QUANTITY2; -- OPM 2434270
     x_line_tbl(l_count).ORDERED_QUANTITY_UOM2  := l_implicit_rec.ORDERED_QUANTITY_UOM2; -- OPM 2434270
     x_line_tbl(l_count).ORG_ID              := l_implicit_rec.ORG_ID;
     x_line_tbl(l_count).payment_term_id     := l_implicit_rec.PAYMENT_TERM_ID;
     x_line_tbl(l_count).planning_priority     := l_implicit_rec.PLANNING_PRIORITY;
     x_line_tbl(l_count).preferred_grade     := l_implicit_rec.PREFERRED_GRADE;
     x_line_tbl(l_count).price_list_id       := l_implicit_rec.PRICE_LIST_ID;
        x_line_tbl(l_count).pricing_date        := l_implicit_rec.PRICING_DATE;
        x_line_tbl(l_count).pricing_quantity    := l_implicit_rec.PRICING_QUANTITY;
        x_line_tbl(l_count).pricing_quantity_uom := l_implicit_rec.PRICING_QUANTITY_UOM;
x_line_tbl(l_count).promise_date        := l_implicit_rec.PROMISE_DATE;
x_line_tbl(l_count).request_date        := l_implicit_rec.REQUEST_DATE;
x_line_tbl(l_count).shipment_priority_code := l_implicit_rec.SHIPMENT_PRIORITY_CODE;
 x_line_tbl(l_count).shipping_method_code := l_implicit_rec.SHIPPING_METHOD_CODE;
x_line_tbl(l_count).ship_from_org_id    := l_implicit_rec.SHIP_FROM_ORG_ID;
        x_line_tbl(l_count).shippable_flag := l_implicit_rec.SHIPPABLE_FLAG;
        x_line_tbl(l_count).ship_set_id    := l_implicit_rec.ship_set_id;
        x_line_tbl(l_count).ship_to_org_id      := l_implicit_rec.SHIP_TO_ORG_ID;
        x_line_tbl(l_count).sold_to_org_id      := l_implicit_rec.SOLD_TO_ORG_ID;
        x_line_tbl(l_count).sold_from_org_id      := l_implicit_rec.SOLD_FROM_ORG_ID;
        x_line_tbl(l_count).source_type_code        := l_implicit_rec.SOURCE_TYPE_CODE;
        x_line_tbl(l_count).split_from_line_id      := l_implicit_rec.SPLIT_FROM_LINE_ID;
        x_line_tbl(l_count).unit_list_price     := l_implicit_rec.UNIT_LIST_PRICE;
        x_line_tbl(l_count).unit_list_price_per_pqty     := l_implicit_rec.UNIT_LIST_PRICE_PER_PQTY;
        x_line_tbl(l_count).unit_selling_price  := l_implicit_rec.UNIT_SELLING_PRICE;
  x_line_tbl(l_count).unit_selling_price_per_pqty  := l_implicit_rec.UNIT_SELLING_PRICE_PER_PQTY;
           x_line_tbl(l_count).unit_list_percent := l_implicit_rec.unit_list_percent;
    x_line_tbl(l_count).unit_selling_percent := l_implicit_rec.unit_selling_percent;
 x_line_tbl(l_count).unit_percent_base_price := l_implicit_rec.unit_percent_base_price;
           x_line_tbl(l_count).calculate_price_flag := l_implicit_rec.calculate_price_flag;
	   x_line_tbl(l_count).charge_periodicity_code := l_implicit_rec.charge_periodicity_code; --rc
        x_line_tbl(l_count).lock_control:= l_implicit_rec.lock_control;

           -- set values for non-DB fields
           x_line_tbl(l_count).db_flag          := FND_API.G_TRUE;
           x_line_tbl(l_count).operation                := FND_API.G_MISS_CHAR;
           x_line_tbl(l_count).return_status    := FND_API.G_MISS_CHAR;
           x_line_tbl(l_count).change_reason    := FND_API.G_MISS_CHAR;
           x_line_tbl(l_count).change_comments  := FND_API.G_MISS_CHAR;
     l_count := l_count + 1;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    AND
    (x_line_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.QUERY_LINES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

           RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Lines;

--  Procedure Query_Line

PROCEDURE Query_Line
(   p_line_id                       IN  NUMBER
,   x_line_rec                      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
)
IS
l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' QUERY_LINE' ) ;
    END IF;
    Query_Lines
        (   p_line_id                     => p_line_id
           , p_header_id                   => Null
           ,   x_line_tbl                    => l_line_tbl
        );

        x_line_rec := l_line_tbl(1);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' LEAVING QUERY_LINE' ) ;
    END IF;
END Query_Line;

Function Enforce_list_Price
return varchar2
is
l_enforce_price_flag    varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.ENFORCE_PRICE_LISTS_FLAG' , 1 ) ;
      END IF;
      begin

        G_STMT_NO := 'Enforce_Price_lists_Flag#10';
	-- changes for bug 4200055
	IF ( OE_Order_PUB.G_Line.Line_Type_id is not null
         AND OE_Order_PUB.G_Line.Line_Type_id <> FND_API.G_MISS_NUM ) THEN
             if (OE_Order_Cache.g_line_type_rec.line_type_id <> OE_Order_PUB.G_Line.Line_Type_id) then
		  OE_Order_Cache.Load_Line_type(OE_Order_PUB.G_Line.Line_Type_id) ;
      	     end if ;
	     if (OE_Order_Cache.g_line_type_rec.line_type_id = OE_Order_PUB.G_Line.Line_Type_id ) then
	         l_enforce_price_flag := nvl(OE_Order_Cache.g_line_type_rec.enforce_line_prices_flag,'N') ;
	     else
		 l_enforce_price_flag := 'N';
             end if ;
       ELSE
		 l_enforce_price_flag := 'N';
       END IF ;
       /* select nvl(enforce_line_prices_flag,'N') into l_enforce_price_flag
        from oe_line_types_v where line_type_id=OE_Order_PUB.G_Line.Line_Type_id; */
       --end bug 4200055
       -- exception when no_data_found then
       exception when others then
                l_enforce_price_flag := 'N';
       end ;

      If l_enforce_price_flag='N' then
      begin
        G_STMT_NO := 'Enforce_Price_lists_Flag#20';
	--changes for bug 4200055
       IF ( OE_Order_PUB.G_Hdr.Order_Type_id is not null
         AND OE_Order_PUB.G_Hdr.Order_Type_id <> FND_API.G_MISS_NUM ) THEN
           if  (OE_Order_Cache.g_order_type_rec.order_type_id <> OE_Order_PUB.G_Hdr.Order_Type_id) then
	       	  OE_Order_Cache.Load_Order_type(OE_Order_PUB.G_Hdr.Order_Type_id) ;
           end if ;
	   if (OE_Order_Cache.g_order_type_rec.order_type_id = OE_Order_PUB.G_Hdr.Order_Type_id ) then
	     l_enforce_price_flag := nvl(OE_Order_Cache.g_order_type_rec.enforce_line_prices_flag,'N') ;
	   else
	     l_enforce_price_flag := 'N';
           end if ;
	ELSE
	     l_enforce_price_flag := 'N';
	END IF ;
        /*select nvl(enforce_line_prices_flag,'N') into l_enforce_price_flag
        from oe_Order_types_v where Order_type_id=OE_Order_PUB.g_hdr.Order_Type_Id;*/
	-- end bug 4200055
        -- exception when no_data_found then
        exception when others then
                l_enforce_price_flag := 'N';
       end ;
     end if;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.ENFORCE_PRICE_LISTS_FLAG' , 1 ) ;
        END IF;

Return l_enforce_price_flag;

end Enforce_list_Price;

Function Get_Rounding_factor(p_list_header_id number)
return number
is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_ROUNDING_FACTOR'||G_ROUNDING_FACTOR_REC.ROUNDING_FACTOR , 3 ) ;
  END IF;
        If g_rounding_factor_rec.list_header_id = p_list_header_id then
                Return g_rounding_factor_rec.rounding_factor;
        Else
                g_rounding_factor_rec.list_header_id := p_list_header_id;
                select rounding_factor into g_rounding_factor_rec.rounding_factor from
                qp_list_headers_b where list_header_id=p_list_header_id;

                If g_rounding_factor_rec.rounding_factor = fnd_api.g_miss_num then
                        g_rounding_factor_rec.rounding_factor:= Null;
                End If;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ROUNDING FACTOR'||G_ROUNDING_FACTOR_REC.ROUNDING_FACTOR , 3 ) ;
                END IF;
                Return g_rounding_factor_rec.rounding_factor;

        End if;
        Exception when no_data_found then
                Return Null;
end Get_Rounding_factor;

procedure Append_asked_for(
	p_header_id		number
	,p_Line_id			number
	,p_line_index				number
        ,px_line_attr_index   in out NOCOPY number
)
is
i	pls_integer;
-- Using union all to eliminate sort unique
cursor asked_for_cur is
	select flex_title, pricing_context, pricing_attribute1,
	pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
	pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
	pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
	pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
	pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
	pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
	pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
	pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
	pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
	pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
	pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
	pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
	pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
	pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
	pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
	pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
	pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
	pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
	pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
	pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
	pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
	pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
	pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
	pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
	pricing_attribute98 , pricing_attribute99 , pricing_attribute100
	,Override_Flag
 from oe_order_price_attribs a
 where (a.line_id is null and a.header_id = p_header_id )
union all
	select flex_title, pricing_context, pricing_attribute1,
	pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
	pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
	pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
	pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
	pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
	pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
	pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
	pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
	pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
	pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
	pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
	pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
	pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
	pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
	pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
	pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
	pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
	pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
	pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
	pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
	pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
	pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
	pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
	pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
	pricing_attribute98 , pricing_attribute99 , pricing_attribute100
	,Override_Flag
 from oe_order_price_attribs a
 where (p_line_id is not null and a.line_id = p_line_id);

--l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
px_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
k NUMBER := px_line_attr_index;
l_attribute_type varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
	G_STMT_NO := 'Append_asked_for#10';
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.APPEND_ASKED_FOR' , 1 ) ;
	END IF;
	for asked_for_rec in asked_for_cur loop
         If asked_for_rec.flex_title = 'QP_ATTR_DEFNS_PRICING' then
           if asked_for_rec.PRICING_ATTRIBUTE1 is not null then
                       i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE1';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE1;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE2 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE2';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE2;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE3 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE3';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE3;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE4 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE4';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE4;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE5 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE5';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE5;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE6 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE6';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE6;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE7 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE7';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE7;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE8 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE8';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE8;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE9 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE9';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE9;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE10 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE10';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE10;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE11 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE11';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE11;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE12 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE12';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE12;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE13 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE13';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE13;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE14 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE14';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE14;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE15 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE15';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE15;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE16 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE16';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE16;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE17 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE17';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE17;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE18 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE18';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE18;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE19 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE19';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE19;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE20 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE20;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE21 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE21';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE21;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE22 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE22';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE22;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE23 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE23';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE23;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE24 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE24';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE24;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE25 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE25';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE25;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE26 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE26';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE26;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE27 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE27';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE27;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE28 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE28';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE28;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE29 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE29';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE29;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE30 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE30';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE30;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE31 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE31';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE31;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE32 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE32';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE32;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE33 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE33';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE33;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE34 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE34';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE34;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE35 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE35';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE35;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE36 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE36';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE36;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE37 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE37';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE37;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE38 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE38';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE38;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE39 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE39';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE39;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE40 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE40';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE40;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE41 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE41';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE41;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE42 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE42';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE42;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE43 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE43';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE43;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE44 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE44';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE44;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE45 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE45';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE45;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE46 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE46';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE46;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE47 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE47';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE47;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE48 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE48';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE48;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE49 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE49';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE49;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE50 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE50';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE50;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE51 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE51';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE51;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE52 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE52';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE52;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE53 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE53';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE53;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE54 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE54';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE54;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE55 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE55';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE55;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE56 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE56';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE56;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE57 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE57';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE57;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE58 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE58';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE58;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE59 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE59';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE59;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE60 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE60';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE60;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE61 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE61';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE61;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE62 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE62';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE62;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE63 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE63';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE63;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE64 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE64';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE64;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE65 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE65';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE65;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE66 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE66';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE66;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE67 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE67';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE67;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE68 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE68';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE68;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE69 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE69';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE69;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE70 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE70';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE70;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE71 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE71';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE71;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE72 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE72';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE72;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE73 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE73';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE73;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE74 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE74';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE74;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE75 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE75';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE75;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE76 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE76';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE76;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE77 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE77';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE77;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE78 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE78';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE78;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE79 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE79';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE79;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE80 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE80';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE80;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE81 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE81';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE81;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE82 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE82';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE82;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE83 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE83';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE83;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE84 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE84';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE84;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE85 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE85';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE85;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE86 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE86';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE86;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE87 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE87';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE87;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE88 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE88';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE88;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE89 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE89';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE89;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE90 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE90';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE90;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE91 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE91';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE91;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE92 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE92';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE92;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE93 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE93';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE93;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE94 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE94';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE94;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE95 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE95';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE95;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE96 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE96';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE96;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE97 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE97';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE97;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE98 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE98';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE98;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE99 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE99';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE99;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE100 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE100';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From:=asked_for_rec.PRICING_ATTRIBUTE100;
		  end if;





		else -- Copy the Qualifiers
		G_STMT_NO := 'Append_asked_for#20';
		  if asked_for_rec.PRICING_ATTRIBUTE1 is not null and asked_for_rec.PRICING_ATTRIBUTE2 is null then -- Promotion
			i := px_Req_line_attr_Tbl.count+1;
               px_Req_line_attr_Tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_line_attr_Tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_Tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE1';
		  	px_Req_line_attr_Tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE1;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE2 is not null then --Deal Component
			i := px_Req_line_attr_Tbl.count+1;
               px_Req_line_attr_Tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_line_attr_Tbl(i).Pricing_Context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_Tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE2';
		  	px_Req_line_attr_Tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE2;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE3 is not null then -- Coupons
			i := px_Req_line_attr_Tbl.count+1;
               px_Req_line_attr_Tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_line_attr_Tbl(i).Pricing_Context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_Tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE3';
		  	px_Req_line_attr_Tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE3;
		  end if;

		end if;

	end loop;

i := px_req_line_attr_tbl.first;
while i is not null loop
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
G_ATTR_LINE_INDEX_tbl(k) := p_line_index; --p_header_id + nvl(p_line_id,0);
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LINE_INDEX:'||G_ATTR_LINE_INDEX_TBL ( K ) ) ;
END IF;
G_ATTR_LINE_DETAIL_INDEX_tbl(k) := NULL;
G_ATTR_ATTRIBUTE_LEVEL_tbl(k) := QP_PREQ_GRP.G_LINE_LEVEL;
G_ATTR_VALIDATED_FLAG_tbl(k) := px_Req_line_attr_Tbl(i).Validated_Flag; --'N';
G_ATTR_ATTRIBUTE_TYPE_tbl(k) := l_attribute_type;
G_ATTR_PRICING_CONTEXT_tbl(k)
      := px_req_line_attr_tbl(i).pricing_context;
G_ATTR_PRICING_ATTRIBUTE_tbl(k)
         := px_req_line_attr_tbl(i).pricing_attribute;
G_ATTR_APPLIED_FLAG_tbl(k) := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
G_ATTR_PRICING_STATUS_CODE_tbl(k) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
G_ATTR_PRICING_ATTR_FLAG_tbl (k) := QP_PREQ_GRP.G_YES;
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
i := px_req_line_attr_tbl.next(i);
end loop;
px_line_attr_index := k;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.APPEND_ASKED_FOR' , 1 ) ;
	END IF;

end Append_asked_for;

procedure Get_the_parent_Line(
   p_Reference_line_Id       Number
,  px_Line_Tbl  in out nocopy OE_Order_Pub.Line_Tbl_Type
,  p_line_Tbl_index        Number
)
is
l_Line_Rec               OE_Order_Pub.Line_Rec_Type;
line_Tbl_Index                  pls_integer;
l_line_index             QP_PREQ_GRP.PLS_INTEGER_TYPE;
l_line_detail_index      QP_PREQ_GRP.PLS_INTEGER_TYPE;
l_relationship_type_code QP_PREQ_GRP.VARCHAR_TYPE;
l_related_line_index     QP_PREQ_GRP.PLS_INTEGER_TYPE;
l_related_line_detail_index QP_PREQ_GRP.PLS_INTEGER_TYPE;
l_status_code            varchar2(1);
l_status_text            varchar2(240);
--bug 3968023 start
l_set_of_books Oe_Order_Cache.Set_Of_Books_Rec_Type;
l_transactional_curr_code VARCHAR2(15);
l_conversion_type_code VARCHAR2(30);
l_conversion_rate NUMBER;
l_conversion_rate_date DATE;
l_denominator     NUMBER;
l_numerator       NUMBER;
l_rate            NUMBER;
--bug 3968023 end

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
        G_STMT_NO := 'Get_the_parent_Line#10';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.GET_THE_PARENT_LINE' , 1 ) ;
        END IF;
        line_Tbl_Index := px_Line_Tbl.First;
        While line_Tbl_Index is not null loop
                If px_Line_Tbl(line_Tbl_Index).line_Id = p_Reference_line_Id  Then
                        Exit;
                End If;
                line_Tbl_Index := px_Line_Tbl.Next(line_Tbl_Index);
        End Loop;

        G_STMT_NO := 'Get_the_parent_Line#20';
       If line_Tbl_Index is null Then
        -- Parent Line is not found in px_line_tbl
                Begin
                        line_Tbl_index := px_line_tbl.count+1;

                        Query_line(p_Reference_line_Id,L_Line_Rec );
                        px_Line_Tbl(line_Tbl_index) := L_Line_Rec;
                        -- Parent Line is only for info purpose, don't calculate price
                     -- px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'N';
                                 -- modified by lkxu, to be used in repricing
                        px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'X';

                        --bug 3968023 start
                        l_set_of_books := Oe_Order_Cache.Load_Set_Of_Books;


                         SELECT  transactional_curr_code,
                                 conversion_type_code,
                                 conversion_rate,
				conversion_rate_date
			INTO    l_transactional_curr_code,
                                 l_conversion_type_code,
                                 l_conversion_rate,
                                 l_conversion_rate_date
                         FROM OE_ORDER_HEADERS_ALL
                         WHERE header_id = l_line_rec.header_id;

                         IF l_debug_level > 0 THEN

                      oe_debug_pub.add('pviprana: l_transactional_curr_code is ' || l_transactional_curr_code);
                            oe_debug_pub.add('pviprana: l_set_of_books.currency_code' || l_set_of_books.currency_code);
                            oe_debug_pub.add('pviprana: l_conversion_type_code' || l_conversion_type_code);
                            oe_debug_pub.add('pviprana: l_conversion_rate_date ' || l_conversion_rate_date);
                            oe_debug_pub.add('pviprana: l_conversion_rate' || l_conversion_rate);
                         END IF;

                      IF (nvl(l_transactional_curr_code, 'XXX') <> nvl(oe_order_pub.g_hdr.transactional_curr_code,'XXX')) THEN
 IF (nvl(l_transactional_curr_code, 'XXX') <> nvl(l_set_of_books.currency_code,'XXX') AND
                            (l_conversion_type_code IS NULL OR
                            (l_conversion_type_code= 'User' AND
                               l_conversion_rate IS NULL))) OR
                             (nvl(oe_order_pub.g_hdr.transactional_curr_code,'XXX') <> nvl(l_set_of_books.currency_code,'XXX') AND
                              (oe_order_pub.g_hdr.conversion_type_code IS NULL OR
                              (oe_order_pub.g_hdr.conversion_type_code= 'User' AND
                              oe_order_pub.g_hdr.conversion_rate IS NULL))) THEN
                                FND_MESSAGE.SET_NAME('ONT', 'ONT_CONV_INFO_NEEDED');
                                FND_MESSAGE.SET_TOKEN('SERVICE_CURR', oe_order_pub.g_hdr.transactional_curr_code);
                                FND_MESSAGE.SET_TOKEN('PARENT_CURR',l_transactional_curr_code);
                                FND_MESSAGE.SET_TOKEN('FUNC_CURR', l_set_of_books.currency_code);
                                OE_MSG_PUB.Add;
                                px_Line_Tbl(line_Tbl_index).unit_list_price := null;
 px_Line_Tbl(line_Tbl_index).unit_list_price_per_pqty := null;
                          ELSE

                             IF nvl(l_transactional_curr_code,'XXX') <> nvl(l_set_of_books.currency_code,'XXX') THEN
                                IF l_debug_level > 0 THEN
                                  oe_debug_pub.add('pviprana: first conversion: conversion_type is '|| l_transactional_curr_code);
                                END IF;
                                gl_currency_api.convert_closest_amount
                                   (  x_from_currency    =>  l_transactional_curr_code
                                      ,  x_to_currency      =>  l_set_of_books.currency_code
                                      ,  x_conversion_date  =>  nvl(l_conversion_rate_date,sysdate)
                                      ,  x_conversion_type  =>  l_conversion_type_code
                                      ,  x_amount           =>  l_line_rec.unit_list_price
                                      ,  x_user_rate        =>  l_conversion_rate
  ,  x_max_roll_days    =>  -1
                                      ,  x_converted_amount =>   px_Line_Tbl(line_Tbl_index).unit_list_price
                                      ,  x_denominator      =>  l_denominator
                                      ,  x_numerator        =>  l_numerator
                                      ,  x_rate             =>  l_rate
                                      );

                            END IF;

                            IF nvl(l_set_of_books.currency_code,'XXX') <> nvl(oe_order_pub.g_hdr.transactional_curr_code,'XXX') THEN
                               IF l_debug_level > 0 THEN
                                  oe_debug_pub.add('pviprana: second conversion: conversion_type is '|| oe_order_pub.g_hdr.conversion_type_code);
                               END IF;
                               gl_currency_api.convert_closest_amount
                                  (  x_from_currency    =>  l_set_of_books.currency_code
                                     ,  x_to_currency      =>  oe_order_pub.g_hdr.transactional_curr_code
                                     ,  x_conversion_date  =>  nvl(oe_order_pub.g_hdr.conversion_rate_date,sysdate)
   ,  x_conversion_type  =>  oe_order_pub.g_hdr.conversion_type_code
                                     ,  x_amount           =>  px_Line_Tbl(line_Tbl_index).unit_list_price
                                     ,  x_user_rate        =>  oe_order_pub.g_hdr.conversion_rate
                                     ,  x_max_roll_days    =>  -1
                                     ,  x_converted_amount =>   px_Line_Tbl(line_Tbl_index).unit_list_price
                                     ,  x_denominator      =>  l_denominator
                                     ,  x_numerator        =>  l_numerator
                                     ,  x_rate             =>  l_rate
                                     );

                            END IF;
 px_Line_Tbl(line_Tbl_index).unit_list_price_per_pqty := px_Line_Tbl(line_Tbl_index).unit_list_price * px_Line_Tbl(line_Tbl_index).ordered_quantity / nvl(px_Line_Tbl(line_Tbl_index).pricing_quantity,px_Line_Tbl(line_Tbl_index).ordered_quantity);
                            IF l_debug_level > 0 THEN
                               oe_debug_pub.add('pviprana: unit_list_price_per_pqty '||px_Line_Tbl(line_Tbl_index).unit_list_price_per_pqty );
                            END IF;
                         END IF;
                      END IF;

                --bug 3968023 end

                Exception when No_Data_Found Then
                        Null;
		WHEN OTHERS THEN
                      IF l_debug_level > 0 THEN
                         oe_debug_pub.add('pviprana: error while converting the parent lines unit_list_price to the service orders currency' );
                      END IF;
                      px_Line_Tbl(line_Tbl_index).unit_list_price := null;
                      px_Line_Tbl(line_Tbl_index).unit_list_price_per_pqty := null;

                End;
        End If;

 BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSERT INTO RLTD LINES TBL FOR SERVICE' , 3 ) ;
   END IF;

-- Added if condition for Bug 2604056

 IF px_Line_Tbl.EXISTS(line_Tbl_index) THEN

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
    l_line_index(1) :=  line_Tbl_Index; --px_line_tbl(line_tbl_index).header_id + px_line_tbl(line_tbl_index).line_id;
    l_line_detail_index(1) := NULL;
    l_relationship_type_code(1) := QP_PREQ_GRP.G_SERVICE_LINE;
    l_related_line_index(1) := p_line_Tbl_index;  --px_line_tbl(p_line_tbl_index).header_id + px_line_tbl(p_line_tbl_index).line_id;
    l_related_line_detail_index(1) := NULL;

    QP_PREQ_GRP.INSERT_RLTD_LINES2(
                  p_LINE_INDEX => l_line_index
                 ,p_LINE_DETAIL_INDEX => l_line_detail_index
                 ,p_RELATIONSHIP_TYPE_CODE => l_relationship_type_code
                 ,p_RELATED_LINE_INDEX => l_related_line_index
                 ,p_RELATED_LINE_DETAIL_INDEX => l_related_line_detail_index
                 ,x_status_code  => l_status_code
                 ,x_status_text  => l_status_text
                );

    IF l_status_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
       oe_debug_pub.add('QP_PREQ_GRP.INSERT_RLTD_LINES2 has reported errors:'||SQLERRM);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_status_code = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add('QP_PREQ_GRP.INSERT_RLTD_LINES2 has reported errors:'||SQLERRM);
          RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE  --lower than 110510
 INSERT INTO QP_PREQ_RLTD_LINES_TMP
             (LINE_INDEX,
              LINE_DETAIL_INDEX,
              RELATIONSHIP_TYPE_CODE,
              RELATED_LINE_INDEX,
              RELATED_LINE_DETAIL_INDEX,
              REQUEST_TYPE_CODE,
              PRICING_STATUS_CODE)

 VALUES     (  line_Tbl_Index /*px_line_tbl(line_tbl_index).header_id
                   + px_line_tbl(line_tbl_index).line_id*/,
               NULL,
               QP_PREQ_GRP.G_SERVICE_LINE,
               p_line_tbl_index /*px_line_tbl(p_line_tbl_index).header_id
                   + px_line_tbl(p_line_tbl_index).line_id*/,
               NULL,
               'NULL',
               QP_PREQ_PUB.G_STATUS_UNCHANGED
            );
  END IF;
 End If;
 EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR INSERTING'||SQLERRM , 3 ) ;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.GET_THE_PARENT_LINE' , 1 ) ;
 END IF;

End Get_the_parent_Line;

procedure Get_PRG_Lines(
   p_line_Id       Number
,  px_Line_Tbl  in out nocopy OE_Order_Pub.Line_Tbl_Type
,  p_line_Tbl_index        Number
)
is
l_Line_Rec               OE_Order_Pub.Line_Rec_Type;
line_Tbl_Index                  pls_integer;
  Cursor prg_lines is
   select adj1.line_id prg_line_id, assoc.rltd_price_adj_id
   from oe_price_adjustments adj1,
	oe_price_adj_assocs  assoc,
	oe_price_adjustments adj2
   where adj1.price_adjustment_id = assoc.rltd_price_adj_id AND
	 assoc.price_adjustment_id = adj2.price_adjustment_id AND
	 adj2.list_line_type_code = 'PRG' AND
	 adj2.line_id = p_line_id;
l_prg_line_id NUMBER;
l_rltd_price_adj_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
        G_STMT_NO := 'Get_prg_Line#10';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.GET_PRG_LINES'||P_LINE_ID , 1 ) ;
        END IF;

      for i in prg_lines loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PRG LINE ID = ' || I.PRG_LINE_ID ) ;
        END IF;
                BEGIN
                        Query_line(i.prg_line_Id,L_Line_Rec );
                        line_Tbl_index := px_line_tbl.last + 1;
                        --if (line_tbl_index > 3) then return;end if;
                        px_Line_Tbl(line_Tbl_index) := L_Line_Rec;
                        -- PRG Line is only for info purpose, don't calculate price
                      px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'N';
                                 -- modified by lkxu, to be used in repricing
                     --   px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'X';
                Exception when No_Data_Found Then
                        Null;
                End;
        End LOOP;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.GET_PRG_LINES' , 1 ) ;
 END IF;

End Get_prg_Lines;

-- 3529369
-- This procedure retrives the service line for the parent. The service lines will be repriced
-- in the case of overriding the list price of the parent
procedure Get_Service_Lines(
   p_line_Id       Number
,  p_header_id     Number
,  px_Line_Tbl  in out nocopy OE_Order_Pub.Line_Tbl_Type
,  p_line_Tbl_index        Number
)
is
l_Line_Rec               OE_Order_Pub.Line_Rec_Type;
line_Tbl_Index                  pls_integer;

CURSOR service_lines is
       select line_id from oe_order_lines_all
       where
       service_reference_line_id=p_line_Id and
       service_reference_type_code='ORDER'and
       header_id=p_header_id and
       original_list_price is NULL;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.GET_SERVICE_LINES'||P_LINE_ID , 1 ) ;
    END IF;

    FOR I in service_lines loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SERVICE LINE ID = ' || I.LINE_ID ) ;
        END IF;
        line_Tbl_Index := px_Line_Tbl.First;

        While line_Tbl_Index is not null loop
                If px_Line_Tbl(line_Tbl_Index).line_Id = I.line_Id  Then
                        Exit;
                End If;
                line_Tbl_Index := px_Line_Tbl.Next(line_Tbl_Index);
        End Loop;
        -- Only if the service line is not already added we add it
        If line_Tbl_Index is null Then
                BEGIN
                        Query_line(I.line_Id,L_Line_Rec );
                        line_Tbl_index := px_line_tbl.last + 1;
                        px_Line_Tbl(line_Tbl_index) := L_Line_Rec;
                Exception when No_Data_Found Then
                        Null;
                End;
        End If;
   End LOOP;
END Get_Service_Lines;
-- 3529369

procedure Get_item_for_iue(px_line_rec   in out nocopy OE_Order_PUB.line_rec_type)
is
-- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
/*l_org_id                 NUMBER := FND_PROFILE.Value('OE_ORGANIZATION_ID');*/
l_ordered_item                  varchar2(300);
cursor adj_cur is
        select modified_from from oe_price_adjustments
        where line_id=px_line_rec.line_id
                and list_line_type_code='IUE';
                --
                l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                --
begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.GET_ITEM_FOR_IUE' , 1 ) ;
         END IF;
         For Adj_rec in Adj_cur loop
          -- There is an item upgrade for this line
           px_line_rec.inventory_item_id := to_number(Adj_rec.modified_from);


           If px_line_rec.item_identifier_type ='INT' then
                px_line_rec.ordered_item_id := to_number(Adj_rec.modified_from);
             Begin
                        SELECT concatenated_segments
                        INTO   px_line_rec.ordered_item
                        FROM   mtl_system_items_kfv
                        WHERE  inventory_item_id = px_line_rec.inventory_item_id
                        AND    organization_id = l_org_id;
                        Exception when no_data_found then
                        Null;
                End;
          End If;
          Exit;
        End Loop;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.GET_ITEM_FOR_IUE' , 1 ) ;
         END IF;
end Get_item_for_iue;


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
 G_CONTRACT_START_DATE_TBL.delete;
 G_CONTRACT_END_DATE_TBL.delete;
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
	G_CHARGE_PERIODICITY_CODE_TBL.delete;
	G_ADDED_PARENT_TBL.delete;
EXCEPTION
WHEN OTHERS THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  L_ROUTINE||': '||SQLERRM , 1 ) ;
END IF;
END reset_all_tbls;

PROCEDURE UPDATE_GLOBAL(p_old_line_rec IN OE_ORDER_PUB.LINE_REC_TYPE,
                        p_line_rec IN OE_ORDER_PUB.LINE_REC_TYPE)
IS
l_notify_index NUMBER;
l_return_status VARCHAR2(1);
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
l_line_rec:= p_line_rec;
--need to update global picture when line changes
   IF l_debug_level > 0 THEN
     oe_debug_pub.add(' Calling update_global_picture to register line changes');
   END IF;

   l_notify_index := NULL;

   OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_header_id=>l_line_rec.header_id,
                    --p_old_line_rec=>p_old_line_rec,
                    --p_line_rec =>p_line_rec,
                    p_line_id => l_line_rec.line_id,
                    x_index => l_notify_index,
                    x_return_status => l_return_status);


   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      oe_debug_pub.add(' Update_global_price called from oe_order_price_pvt.populate_line_tbl reports errors');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_notify_index IS NOT NULL THEN
    IF l_debug_level > 0 THEN
     oe_debug_pub.add(' Global index obtained is:'||l_notify_index);
     oe_debug_pub.add(' Global OLD_LINE USP BEFORE ASSIGNMENT:'||OE_ORDER_UTIL.g_old_line_tbl(l_notify_index).unit_selling_price);
     oe_debug_pub.add(' p_old_line_rec.usp:'||p_old_line_rec.unit_selling_price);
     oe_debug_pub.add(' new line rec.usp:'||l_line_rec.unit_selling_price);
    END IF;
    --update Global Picture directly
    --OE_ORDER_UTIL.g_old_line_tbl(l_notify_index):= p_old_line_rec;

    --As per HASHRAF  12/01/03 05:58 pm in bug 2920261
    --it could potentially undo bug 2806544

    IF  OE_ORDER_UTIL.g_line_tbl.exists(l_notify_index) Then
      If OE_ORDER_UTIL.g_line_tbl(l_notify_index).flow_status_code IS NULL then
	--for the create case
        OE_ORDER_UTIL.g_line_tbl(l_notify_index):= OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
      End If;
    Else
      --The record does not exists at all in g_line_tbl, creating one
      OE_ORDER_UTIL.g_line_tbl(l_notify_index):= OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
    End If;

    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_selling_price:=l_line_rec.unit_selling_price;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_list_price   :=l_line_rec.unit_list_price;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_selling_price_per_pqty:=l_line_rec.unit_selling_price_per_pqty;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_list_price_per_pqty:=l_line_rec.unit_list_price_per_pqty;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).pricing_quantity        :=l_line_rec.pricing_quantity;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).pricing_quantity_uom    :=l_line_rec.pricing_quantity_uom;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).price_list_id           := l_line_rec.price_list_id;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_list_percent       :=l_line_rec.unit_list_percent;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_percent_base_price :=l_line_rec.unit_percent_base_price;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).unit_selling_percent    :=l_line_rec.unit_selling_percent;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).operation               :=l_line_rec.operation;
    --AS per Jyothi Narayan April 23 11:40, we need to assign line_id as well when it is a direct call from booking api

    OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id                 :=nvl(OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id,l_line_rec.line_id);



      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Global picture OLD USP is:'||OE_ORDER_UTIL.G_OLD_LINE_TBL(L_NOTIFY_INDEX).UNIT_SELLING_PRICE);
       oe_debug_pub.add('Global picture NEW USP is:'||OE_ORDER_UTIL.G_LINE_TBL(L_NOTIFY_INDEX).UNIT_SELLING_PRICE) ;
       oe_debug_pub.add('Global picture NEW OPR is:'||OE_ORDER_UTIL.G_LINE_TBL(L_NOTIFY_INDEX).operation);
       oe_debug_pub.add('Global picture OLD QTY is:'||OE_ORDER_UTIL.G_OLD_LINE_TBL(L_NOTIFY_INDEX).ordered_quantity);
       oe_debug_pub.add('Global picture NEW QTY is:'||OE_ORDER_UTIL.G_LINE_TBL(L_NOTIFY_INDEX).ordered_quantity);
      END IF;
   END IF;

END;


PROCEDURE POPULATE_LINE_TBL(
    px_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE
)
IS
lx_old_line_price_tbl OE_ORDER_PUB.LINE_TBL_TYPE;
l_control_rec OE_GLOBALS.Control_Rec_Type;
l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_call_lines BOOLEAN := FALSE;
l_check_sec BOOLEAN := FALSE;
l_line_index NUMBER;
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_validate_desc_flex varchar2(1) := 'N';
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE POPULATE_LINE_TBL:'||PX_LINE_TBL.COUNT , 3 ) ;
  END IF;
 l_line_index := px_line_tbl.first;
 while l_line_index is not null loop
   l_line_rec := px_line_tbl(l_line_index);
  oe_debug_pub.add('Ord Qty:'||l_line_rec.ordered_quantity, 3 ) ;
  if l_line_rec.ordered_quantity <> 0 then  --bug 2823498
   BEGIN
     select /*+ INDEX(lines qp_preq_lines_tmp_n1) */
      nvl(lines.order_uom_selling_price, lines.ADJUSTED_UNIT_PRICE * nvl(lines.priced_quantity,l_line_rec.ordered_quantity)/l_line_rec.ordered_quantity)
    , nvl(lines.line_unit_price, lines.UNIT_PRICE * nvl(lines.priced_quantity,l_line_rec.ordered_quantity)/l_line_rec.ordered_quantity)
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
       and lines.process_status <> 'NOT_VALID'
                  and lines.pricing_status_code in
                 (QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                   QP_PREQ_GRP.G_STATUS_UPDATED);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UNIT_SELLING_PRICE:'||L_LINE_REC.UNIT_SELLING_PRICE||' FOR LINE:'||L_LINE_REC.LINE_ID , 3 ) ;
      oe_debug_pub.add(' QTY:'||l_line_rec.ordered_quantity,3);
     oe_debug_pub.add(  'SCHEDULE_DATE'||L_LINE_REC.SCHEDULE_SHIP_DATE||':'||L_LINE_REC.SCHEDULE_ARRIVAL_DATE ) ;
     oe_debug_pub.add('New price list id : ' ||l_line_rec.price_list_id);
     oe_debug_pub.add('Old price list id : ' ||px_line_tbl(l_line_index).price_list_id);
 END IF;

 --bug 3702538
 If nvl(l_line_rec.price_list_id,-9999) <> nvl(px_line_tbl(l_line_index).price_list_id,-9999) THEN
   l_call_lines := TRUE;
   IF l_line_rec.operation NOT IN (OE_GLOBALS.G_OPR_CREATE, OE_GLOBALS.G_OPR_INSERT) THEN
      l_check_sec := TRUE;
   END IF;
 End If;
 --bug 3702538

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE '||L_LINE_REC.LINE_ID||' DID NOT GET NEW PRICE' ) ;
    END IF;
 END;

   --UPDATE_GLOBAL(p_old_line_rec=>px_line_tbl(l_line_index),p_line_rec=>l_line_rec);

   --bug 3702538
   lx_old_line_price_tbl(l_line_index) := px_line_tbl(l_line_index);
   --bug 3702538
   px_line_tbl(l_line_index) := l_line_rec;
  --For Bug# 7695217
   oe_debug_pub.add('7695217 - l_line_rec.line_id - ' || l_line_rec.line_id);
   IF l_line_rec.line_id < 0 THEN
     l_call_lines := FALSE;
   END IF;
   --End of Bug# 7695217
   end if; --bug 2823498
   l_line_index := px_line_tbl.next(l_line_index);

 END LOOP;
 --bug 3702538
 IF l_call_lines THEN
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.check_security       := l_check_sec;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;
    l_control_rec.process              := FALSE;

    OE_GLOBALS.G_PRICING_RECURSION := 'Y';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'validate desc flex:'||OE_GLOBALS.g_validate_desc_flex) ;
    END IF;
    l_validate_desc_flex := OE_GLOBALS.g_validate_desc_flex;
    OE_GLOBALS.g_validate_desc_flex := 'N';
    OE_Order_Pvt.Lines
    ( p_validation_level  => FND_API.G_VALID_LEVEL_FULL
     ,p_control_rec       => l_control_rec
     ,p_x_line_tbl        => px_line_tbl
     ,p_x_old_line_tbl    => lx_old_line_price_tbl
     ,x_return_status     => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    OE_GLOBALS.g_validate_desc_flex := l_validate_desc_flex;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'reset validate desc flex:'||OE_GLOBALS.g_validate_desc_flex) ;
    END IF;
    OE_GLOBALS.G_PRICING_RECURSION := 'N';
 END IF;
 --bug 3702538
END POPULATE_LINE_TBL;

PROCEDURE SECURITY_AND_GLOBAL_PICTURE(
    px_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE,
    p_write_to_db IN BOOLEAN
)
IS
l_line_index NUMBER;
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
l_old_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
l_sec_result varchar2(1);
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_old_change_reason varchar2(30);
l_old_change_comments varchar2(2000);
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE SECURITY_AND_GLOBAL_PICTURE' , 3 ) ;
  END IF;

  l_line_index := px_line_tbl.first;
  while l_line_index is not null loop
   l_line_rec := px_line_tbl(l_line_index);
   l_old_line_rec := l_line_rec;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE ID'||L_LINE_REC.LINE_ID ) ;
   END IF;
-- bug 4866684 setting the msg context
   OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref
         ,p_source_document_id          => l_line_rec.source_document_id
         ,p_source_document_line_id     => l_line_rec.source_document_line_id
         ,p_order_source_id             => l_line_rec.order_source_id
         ,p_source_document_type_id     => l_line_rec.source_document_type_id);
   BEGIN
     select /*+ INDEX(lines qp_preq_lines_tmp_n1) */
      nvl(lines.order_uom_selling_price, lines.ADJUSTED_UNIT_PRICE * nvl(lines.priced_quantity,l_line_rec.ordered_quantity)/l_line_rec.ordered_quantity)
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
       and l_line_rec.open_flag <> 'N'
       and lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                                  QP_PREQ_GRP.G_STATUS_UPDATED);

  IF (l_line_rec.operation IS NULL
         OR l_line_rec.operation= FND_API.G_MISS_CHAR) THEN
   l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE PRICE'||L_LINE_REC.UNIT_SELLING_PRICE||L_LINE_REC.OPERATION||' '||L_OLD_LINE_REC.OPERATION , 3 ) ;
  END IF;

  --IF (NOT OE_GLOBALS.G_HEADER_CREATED ) THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Checking Security');
      END IF;

     --bug 2823794, the security api doesn't like delete operation.
     --it will raise error if a delete operation is passed.
     --therefore we check, if delete or create operation, do not call the security api.

     IF l_line_rec.operation =  OE_GLOBALS.G_OPR_UPDATE THEN

      -- bug 3554060
      l_old_change_reason := l_line_rec.change_reason;
      l_old_change_comments := l_line_rec.change_comments;
      l_line_rec.change_reason := 'SYSTEM';
      l_line_rec.change_comments := 'REPRICING';
      --end  bug 3554060
      OE_Line_Security.Attributes
                (p_line_rec             => l_line_rec
                , p_old_line_rec   => l_old_line_rec
                , x_result         => l_sec_result
                , x_return_status  => l_return_status
                );

      -- Adding code to log versioning/audit request
      OE_Line_Util.Version_Audit_Process(p_x_line_rec => l_line_rec,
                          p_old_line_rec => l_old_line_rec);

      -- bug 3554060
      l_line_rec.change_reason := l_old_change_reason;
      l_line_rec.change_comments := l_old_change_comments;
      -- end bug 3554060
     END IF;

  --END IF;
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;


              -- if operation on any attribute is constrained
              IF l_sec_result = OE_PC_GLOBALS.YES THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CHECK_SECURITY'||L_SEC_RESULT ) ;
      oe_debug_Pub.add(  'BEFORE UPDATE GLOBAL');
  END IF;

  IF p_write_to_db THEN
    UPDATE_GLOBAL(p_old_line_rec=>l_old_line_rec,p_line_rec=>l_line_rec);
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(' AFTER UPDATE GLOBAL');
     oe_debug_pub.add('old SP :'||l_old_line_rec.unit_selling_price);
     oe_debug_pub.add('new SP :'||l_line_rec.unit_selling_price);
     oe_debug_pub.add('order_source_id:'||l_line_rec.order_source_id);
     oe_debug_pub.add('xml_transaction_type_code:'||l_line_rec.xml_transaction_type_code);
  END IF;

     -- Moved to OE_ACKNOWLEDGMENT_PUB as part of 3417899 and 3412458
     /*  IF l_line_rec.unit_selling_price <> l_old_line_rec.unit_selling_price
     AND OE_Code_Control.code_release_level >= '110510'
     AND NVL(FND_PROFILE.VALUE('ONT_3A7_RESPONSE_REQUIRED'), 'N') = 'Y'
     AND l_line_rec.order_source_id =     OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
     AND nvl(l_line_rec.xml_transaction_type_code, OE_Acknowledgment_Pub.G_TRANSACTION_CSO) = OE_Acknowledgment_Pub.G_TRANSACTION_CSO
     AND nvl(l_line_rec.booked_flag, 'X') = 'Y'
     AND l_line_rec.ordered_quantity <> 0 THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'calling OE_Acknowlegment_PUB.apply_3a7_hold', 2 ) ;
         END IF;
         OE_Acknowledgment_PUB.Apply_3A7_Hold(
                                 p_header_id       =>   l_line_rec.header_id
                             ,   p_line_id         =>   l_line_rec.line_id
                             ,   p_sold_to_org_id  =>   l_line_rec.sold_to_org_id
                             ,   x_return_status   =>   l_return_status);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Return status after call to apply_3a7_hold:' || l_return_status, 2 ) ;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
  END IF;*/
  px_line_tbl(l_line_index) := l_line_rec;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE '||L_LINE_REC.LINE_ID||' DID NOT GET NEW PRICE' ) ;
    END IF;
  END;

  l_line_index := px_line_tbl.next(l_line_index);
 END LOOP;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Leaving SERURITY_AND_GLOBAL_PICTURE');
 END IF;

END SECURITY_AND_GLOBAL_PICTURE;

PROCEDURE CHECK_GSA
IS
l_GSA_Enabled_Flag 	Varchar2(30) := FND_PROFILE.VALUE('QP_VERIFY_GSA');
--l_gsa_violation_action Varchar2(30) := nvl(fnd_profile.value('ONT_GSA_VIOLATION_ACTION'), 'WARNING');
l_gsa_violation_action Varchar2(30) := nvl(oe_sys_parameters.value('ONT_GSA_VIOLATION_ACTION'), 'WARNING'); --moac
l_hold_source_rec			OE_Holds_Pvt.hold_source_rec_type;
l_hold_release_rec  		OE_Holds_Pvt.Hold_Release_REC_Type;
l_return_status			varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                 Varchar2(30);
l_msg_text				Varchar2(200);
l_header_id NUMBER:=oe_order_pub.g_hdr.header_id;
--bug 2028480 begin
l_gsa_released varchar2(1) := 'N';
--bug 2028480 end
CURSOR gsa_violators IS
SELECT ql.LINE_ID, l.ordered_item, l.inventory_item_id, ql.pricing_status_text
FROM QP_PREQ_LINES_TMP ql
,    OE_ORDER_LINES l
WHERE ql.line_id=l.line_id
AND ql.LINE_TYPE_CODE='LINE'
AND ql.PROCESS_STATUS <> 'NOT_VALID'
AND ql.PRICING_STATUS_CODE =
              QP_PREQ_GRP.G_STATUS_GSA_VIOLATION
AND l.ITEM_TYPE_CODE NOT IN ('INCLUDED','CONFIG')
AND l.TRANSACTION_PHASE_CODE ='F'; -- Bug 6617462;
CURSOR updated_lines IS
SELECT LINE_ID FROM QP_PREQ_LINES_TMP
WHERE LINE_TYPE_CODE='LINE'
AND PROCESS_STATUS <> 'NOT_VALID'
AND PRICING_STATUS_CODE = (QP_PREQ_GRP.G_STATUS_UPDATED);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--these variables are introduced for bug 3021992
l_mod_lineid NUMBER;
l_line_num VARCHAR2(10);
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'GSA ENABLED?'||L_GSA_ENABLED_FLAG||' ACTION:'||L_GSA_VIOLATION_ACTION ) ;
   END IF;
   IF (l_GSA_Enabled_Flag = 'Y') THEN

       FOR i IN gsa_violators LOOP
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GSA VIOLATION LINE:'||I.LINE_ID , 3 ) ;
         END IF;
	l_mod_lineid := MOD(i.line_id,2147483647) ;
        IF l_gsa_violation_action = 'WARNING' THEN

        /*  FND_MESSAGE.SET_NAME('ONT','OE_GSA_VIOLATION');
			l_msg_text := i.pricing_status_text||' ( '||nvl(i.ordered_item,i.inventory_item_id)||' )';
		  			FND_MESSAGE.SET_TOKEN('GSA_PRICE',l_msg_text);
		  			OE_MSG_PUB.Add;*/
	--3021992
		IF not(g_lineid_tbl.EXISTS(l_mod_lineid)) THEN
		          FND_MESSAGE.SET_NAME('ONT','OE_GSA_VIOLATION');
			  l_line_num := OE_ORDER_MISC_PUB.get_concat_line_number(i.line_id);
			  l_msg_text := nvl(i.ordered_item,i.inventory_item_id);
		  	  FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_num);
			  FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_msg_text);
			  FND_MESSAGE.SET_TOKEN('GSA_PRICE',i.pricing_status_text);
		  	  OE_MSG_PUB.Add;
	       END IF ;
			g_lineid_tbl(l_mod_lineid) := i.line_id ;
 	 --3021992 ends
        ELSE -- violation action is error
              G_STMT_NO := 'Gsa_Check#20.15';
                 -- bug 1381660, duplicate holds with type_code='GSA'
                 -- use the seeded hold_id
                 l_hold_source_rec.hold_id := G_SEEDED_GSA_HOLD_ID;

				If i.line_id is null or
					i.line_id = fnd_api.g_miss_num then
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','GSA_INVALID_LINE_ID');
		  			OE_MSG_PUB.Add;
					 RAISE FND_API.G_EXC_ERROR;
				End if;

	 			G_STMT_NO := 'Gsa_Check#20.20';
			l_hold_source_rec.hold_entity_id := l_header_id;
                             l_hold_source_rec.header_id := l_header_id;
                                l_hold_source_rec.line_id := i.line_id;
				l_hold_source_rec.Hold_Entity_code := 'O';
--for bug 2028480   Begin
--check if hold released earlier for this line , if so, do not go
--thru the holds logic
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'HOLD ID :'||L_HOLD_SOURCE_REC.HOLD_ID ) ;
        END IF;
        Begin
 --changed select below to fix bug 3039915
          select 'Y' into l_gsa_released from
          oe_order_holds ooh,oe_hold_sources ohs,oe_hold_releases ohr
          where ooh.line_id = i.line_id
          and ooh.hold_source_id = ohs.hold_source_id
          and ohr.hold_release_id = ooh.hold_release_id
          and ohs.hold_id = l_hold_source_rec.hold_id
          and ohr.created_by <> 1
          and ohr.release_reason_code <> 'PASS_GSA' ;
        exception
          when others then
            l_gsa_released := 'N';
        end;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'GSA RELEASED VALUE :'||L_GSA_RELEASED ) ;
        END IF;
--for bug 2028480   end
                 if l_gsa_released = 'N' then --for bug 2028480
                 -- check if line already on gsa hold, place hold if not
  			        OE_Holds_Pub.Check_Holds(
					p_api_version		=> 1.0
                                        ,p_header_id            => l_header_id
					,p_line_id		=> i.line_id
					,p_hold_id		=> l_hold_source_rec.Hold_id
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					,x_result_out		=> l_x_result_out
					);

  			        If  l_x_result_out = FND_API.G_FALSE then
                                  IF l_debug_level  > 0 THEN
                                      oe_debug_pub.add(  'HOLD LINE WITH HEADER_ID:'||L_HEADER_ID||' LINE_ID: '||I.LINE_ID , 1 ) ;
                                  END IF;
				  OE_HOLDS_PUB.Apply_Holds(
					p_api_version	=> 1.0
					,p_hold_source_rec	=> l_hold_source_rec
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					);

				  If l_return_status = FND_API.g_ret_sts_success then

		  			/*FND_MESSAGE.SET_NAME('ONT','OE_GSA_HOLD_APPLIED');
		  			OE_MSG_PUB.Add;*/
	     			--3021992
				    if not(g_lineid_tbl.EXISTS(l_mod_lineid)) THEN
		  			FND_MESSAGE.SET_NAME('ONT','OE_GSA_HOLD_APPLIED');
		  			OE_MSG_PUB.Add;
				    END IF;
				    g_lineid_tbl(l_mod_lineid) := i.line_id;
				  --3021992 ends

				  Else
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','APPLY_GSA_HOLD');
		  			OE_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				  End If;
                                End If; /* check hold */
                         End if; --for bug 2028480
			End if;  /* violation action */
       END LOOP;

    IF (l_gsa_violation_action = 'ERROR') THEN
     FOR i in updated_lines LOOP
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATING LINE:'||I.LINE_ID||' RELEASING HOLD IF ANY' , 3 ) ;
         END IF;
      -- release hold if there is one

			If l_hold_source_rec.hold_id is null or
					l_hold_source_rec.hold_id = fnd_api.g_miss_num then
	 			G_STMT_NO := 'Gsa_Check#20.25';
                                -- bug 1381660, duplicate holds with type_code='GSA'
                                -- use the seeded hold_id
                                l_hold_source_rec.hold_id := G_SEEDED_GSA_HOLD_ID;

			End if; -- Hold id
	 		G_STMT_NO := 'Gsa_Check#20.30';

				l_hold_source_rec.hold_entity_id := l_header_id;
                                l_hold_source_rec.header_id := l_header_id;
                                l_hold_source_rec.line_id := i.line_id;
				l_hold_source_rec.Hold_Entity_code := 'O';

			OE_Holds_Pub.Check_Holds(
					p_api_version		=> 1.0
                                        ,p_header_id            => l_header_id
					,p_line_id		=> i.line_id
					,p_hold_id		=> l_hold_source_rec.Hold_id
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					,x_result_out		=> l_x_result_out
					);

              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

			If  l_x_result_out = FND_API.G_TRUE then
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'RELEASING GSA_HOLD ON LINE'||I.LINE_ID , 3 ) ;
                            END IF;
				-- Hold is found , Release the hold.

	 			G_STMT_NO := 'Gsa_Check#20.35';
			l_hold_release_rec.release_reason_code :='PASS_GSA';
  --for bug 3039915 set created_by = 1  to indicate automatic hold release
		l_hold_release_rec.created_by := 1;

				OE_Holds_Pub.Release_Holds(
					p_api_version	=> 1.0
--					,p_hold_id		=> l_hold_source_rec.Hold_id
--					,p_entity_code 	=> l_hold_source_rec.Hold_entity_code
--					,p_entity_id		=> l_hold_source_rec.Hold_entity_id
                                        ,p_hold_source_rec      => l_hold_source_rec
					,p_hold_release_rec	=> l_hold_release_rec
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					);

				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'ERROR WHILE RELEASING GSA HOLD' ) ;
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'ERROR WHILE RELEASING GSA HOLD' ) ;
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			End if; -- Release Hold

           END LOOP;
	 End If; -- GSA Violation

  END IF;  -- gsa_enabled
END Check_GSA;

PROCEDURE UPDATE_ORDER_HEADER(
   px_header_rec IN OE_ORDER_PUB.HEADER_REC_TYPE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 NULL;
/*
  IF (px_header_rec.price_request_code IS NULL)
  THEN
    oe_debug_pub.add('update order header with price_request_code');

     update oe_order_headers
     set price_request_code
    = (select price_request_code
       from qp_preq_lines_tmp
       where line_type_code='ORDER'
       and line_id=px_header_rec.header_id);
    oe_debug_pub.add('done updating header');
  END IF;
*/
EXCEPTION
  WHEN NO_DATA_FOUND THEN

   NULL;
END UPDATE_ORDER_HEADER;

PROCEDURE LOG_REQUEST(
   px_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE
)
IS
l_verify_payment varchar2(1);
l_commitment_sequencing boolean
   := OE_COMMITMENT_PVT.Do_Commitment_Sequencing;
l_return_status varchar2(1);
l_tax_event_code number := 0;
l_tax_calculation_flag varchar2(1):=NULL;
l_tax_calc_rec OE_ORDER_CACHE.Tax_Calc_Rec_Type;
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
l_order_adj_changed_flag varchar2(1);
l_commt_tax_flag varchar2(1);  --bug 2505961
cursor updated_lines IS
  SELECT l.LINE_ID
       , l.UNIT_SELLING_PRICE_PER_PQTY
       , l.unit_selling_price usp
       , LINES.ADJUSTED_UNIT_PRICE
       , lines.order_uom_Selling_price ousp
       , l.COMMITMENT_ID
       , l.BOOKED_FLAG
       , l.LINE_CATEGORY_CODE
       , l.line_type_id
       , l.shippable_flag
       , l.shipped_quantity
       , l.tax_exempt_flag
       , l.org_id
       , l.header_id
       , l.reference_line_id
       , l.return_context
       , l.reference_customer_trx_line_id
       -- BLANKETS: select following fields for logging request
       -- to update blanket amount
       , nvl(lines.order_uom_selling_price, lines.ADJUSTED_UNIT_PRICE*nvl(lines.priced_quantity,l.ordered_quantity)/l.ordered_quantity) new_selling_price
       , l.blanket_number
       , l.blanket_line_number
       , l.unit_selling_price
       , l.ordered_quantity
       , l.pricing_quantity
       , l.order_quantity_uom
       , l.fulfilled_flag
       , l.line_set_id
       , l.inventory_item_id
       , l.sold_to_org_id
       , l.transaction_phase_code--for bug 3108881
       , l.order_source_id
  FROM QP_PREQ_LINES_TMP lines
     , OE_ORDER_LINES l
  WHERE lines.pricing_status_code IN
       ( QP_PREQ_GRP.G_STATUS_UPDATED
       , QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
      AND lines.process_status <> 'NOT_VALID'
      AND lines.line_type_code='LINE'
      AND (lines.adjusted_unit_price <> nvl(l.unit_selling_price_per_pqty,0)
           or nvl(lines.order_uom_Selling_price,0) <> nvl(l.unit_selling_price,0))
      AND l.ordered_quantity <> 0 -- bug 3958480
      AND l.line_id = lines.line_id;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_notify_index NUMBER:=NULL;
--bug 4332307
  l_header_id    Number;
  l_log_mrg_hold_req Varchar2(1) := 'N';
Begin

  -- Log delayed requests for the attributes change on the line
  BEGIN
           IF OE_Order_pub.g_hdr.order_type_id is not null THEN

	      --changes for bug 4200055
	  IF ( OE_Order_PUB.G_Hdr.Order_Type_id <> FND_API.G_MISS_NUM ) THEN
           	if  (OE_Order_Cache.g_order_type_rec.order_type_id <> OE_Order_PUB.G_Hdr.Order_Type_id) then
	       	  	OE_Order_Cache.Load_Order_type(OE_Order_PUB.G_Hdr.Order_Type_id) ;
                end if ;
		if (OE_Order_Cache.g_order_type_rec.order_type_id = OE_Order_PUB.G_Hdr.Order_Type_id ) then
               		if (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code = 'ENTERING') then
				l_tax_event_code := 0;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code = 'BOOKING') then
				l_tax_event_code := 1;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code = 'SHIPPING') then
				l_tax_event_code := 2;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code = 'INVOICING') then
				l_tax_event_code := 3;
			else
				l_tax_event_code := -1;
                        end if ;
		else
				l_tax_event_code := 0 ;
	        end if ;
	 ELSE
			l_tax_event_code := 0 ;
	 END IF ;

            /*SELECT DECODE( TAX_CALCULATION_EVENT_CODE, 'ENTERING',   0,
                                                  'BOOKING', 1,
                                                  'SHIPPING', 2,
                                                  'INVOICING', 3,
                                                  -1)
            into l_tax_event_code
            from oe_transaction_types_all
            where transaction_type_id = OE_Order_pub.g_hdr.order_type_id;*/
	   -- end bug 4200055
         END IF;

  EXCEPTION
           when no_data_found then
                 l_tax_event_code := 0;
           when others then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'REN: FAILED WHILE QUERY UP TAX_EVENT' ) ;
             END IF;
             RAISE;

  END;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TAX EVENT CODE'||L_TAX_EVENT_CODE ) ;
  END IF;

  for update_line in updated_lines loop
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOG REQUEST FOR UPDATED LINE '||UPDATE_LINE.LINE_ID ) ;
        oe_debug_pub.add('adjusted_unit_price : '||update_line.adjusted_unit_price);
        oe_debug_pub.add('order_uom_selling_price : '||update_line.ousp);
        oe_debug_pub.add('unit_selling_price_per_pqty : '||update_line.unit_selling_price_per_pqty);
        oe_debug_pub.add('unit_selling_price : '||update_line.usp);
    END IF;
    -- Delayed Requests to be logged if selling price change
    -- Tax, Verify_Payment, Commitment
    --populate a temp l_line_rec, only fields necessary to get tax flag
    l_line_rec.line_id := update_line.line_id;
    l_line_rec.header_id := update_line.header_id;
    l_line_rec.reference_line_id := update_line.reference_line_id;
    l_line_rec.line_type_id := update_line.line_type_id;
    l_line_rec.org_id := update_line.org_id;
    l_line_rec.line_category_code := update_line.line_category_code;
    l_line_rec.return_context := update_line.return_context;
    l_line_Rec.reference_customer_trx_line_id
                    := update_line.reference_customer_trx_line_id;
    l_tax_calc_rec := oe_order_cache.get_tax_calculation_flag
                                 (update_line.line_type_id,
                                  l_line_rec);

    l_tax_calculation_flag := l_tax_calc_rec.tax_calculation_flag;
    --changes for bug 2505961    Begin
    --commented the following for bug7306510 as the sql execution is no more required
    /*if update_line.commitment_id is not null
       and update_line.commitment_id <> FND_API.G_MISS_NUM then
     begin
      select nvl(tax_calculation_flag,'N') into l_commt_tax_flag
      from ra_cust_trx_types_all  ract where ract.cust_trx_type_id =
      (
      select nvl(cust_type.subsequent_trx_type_id,cust_type.cust_trx_type_id)
      from ra_cust_trx_types  cust_type,ra_customer_trx_all cust_trx  where
      cust_type.cust_trx_type_id = cust_trx.cust_trx_type_id
      and cust_trx.customer_trx_id = update_line.commitment_id
      );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_COMMIT TAX FLAG: '||L_COMMT_TAX_FLAG , 1 ) ;
      END IF;
     exception
      when others then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN EXCEPTION COMMITMENT ' , 1 ) ;
      END IF;
      l_commt_tax_flag := 'N';
     end;
    end if;
    */
    --changes for bug 2505961   end

 --l_tax_calculation_flag := 'Y';

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'L_TAX_CALCULATION_FLAG'||L_TAX_CALCULATION_FLAG ) ;
 END IF;

 -- commented portion of the following condition for bug7306510
       -- with ebtax upkae in R12 ,meaning of ra_cust_trx_types.tax_calculation_flag has changed
       -- now this flag will be checcked by customers only if they want the 11i migrated Tax Classification
       -- code approach,other wise tax will be calculated based on tax rules .It no more controls wheter tax code  is a  required  filed in AR transactions or not
       -- OM will depend on Tax_event alone ( specfied transaction type level) to automatically trigger
       -- tax calcualtion .ra_cust_trx_types.tax_calculation_flag is no more considered while logging delayed requests for tax


 IF ((l_tax_event_code = 0 OR
     (l_tax_event_code = 1 AND nvl(update_line.booked_flag,'X') = 'Y') OR
     (l_tax_event_code = 2 AND (update_line.shippable_flag = 'N' OR (update_line.shippable_flag = 'Y' and update_line.shipped_quantity IS NOT NULL))) OR
     l_tax_event_code = -1)
    --AND 7306510 (l_tax_calculation_flag = 'Y' OR
        --update_line.tax_exempt_flag = 'R' OR l_commt_tax_flag = 'Y' )
    ) THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR TAXING' ) ;
            END IF;
            l_commt_tax_flag := 'N' ;  --bug 2505961
            -- lkxu, make changes for bug 1581188
          IF (OE_GLOBALS.G_UI_FLAG) THEN
            OE_delayed_requests_Pvt.log_request(
                p_entity_code           => OE_GLOBALS.G_ENTITY_LINE,
                p_entity_id             => update_line.line_id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                p_requesting_entity_id   => update_line.line_id,
                p_request_type          => OE_GLOBALS.g_tax_line,
                x_return_status         => l_return_status);
          ELSE
            -- added p_param1 for bug 1786533.
            OE_delayed_requests_Pvt.log_request(
                p_entity_code           => OE_GLOBALS.G_ENTITY_ALL,
                p_entity_id             => update_line.line_id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                p_requesting_entity_id   => update_line.line_id,
                p_request_type          => OE_GLOBALS.g_tax_line,
                --p_param1                => l_param1,
                x_return_status         => l_return_status);
          END IF;
          oe_globals.g_tax_flag := 'N';
        END IF;

  l_verify_payment := 'N';
  IF OE_ORDER_PUB.G_HDR.PAYMENT_TYPE_CODE = 'CREDIT_CARD' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CREDIT CARD:'||UPDATE_LINE.ADJUSTED_UNIT_PRICE||'>'||UPDATE_LINE.UNIT_SELLING_PRICE_PER_PQTY||'?' ) ;
    END IF;
     IF update_line.adjusted_unit_price > update_line.unit_selling_price_per_pqty or
        nvl(update_line.ousp,0) > nvl(update_line.usp,0)
     THEN
        -- Log Request if commitment id is NULL
        IF update_line.commitment_id is NULL THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOG VERIFY PAYMENT DELAYED REQUSET IN SELLING PRICE' ) ;
         END IF;
         l_verify_payment := 'Y';
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COMMITMENT:'||UPDATE_LINE.COMMITMENT_ID ) ;
          END IF;
        END IF;
      END IF;
  ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PAYMENT TYPE:'||OE_ORDER_PUB.G_HDR.PAYMENT_TYPE_CODE||' BOOKED?'||UPDATE_LINE.BOOKED_FLAG ) ;
     END IF;
     IF nvl(update_line.booked_flag,'X') = 'Y' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LOG VERIFY PAYMENT REQUEST' ) ;
       END IF;
       l_verify_payment := 'Y';
     END IF;
  END IF;  -- credit card;

  IF (l_verify_payment = 'Y' AND update_line.line_category_code <> 'RETURN') THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR VERIFY PAYMENT' ) ;
          END IF;
          --
       OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => oe_order_pub.g_hdr.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id   => update_line.line_id,
                   p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                   x_return_status          => l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COMMITMENT '||UPDATE_LINE.COMMITMENT_ID ) ;
  END IF;

  IF l_commitment_sequencing AND update_line.commitment_id IS NOT NULL  THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR COMMITMENT.' , 2 ) ;
        END IF;
        OE_Delayed_Requests_Pvt.Log_Request(
        p_entity_code                   =>      OE_GLOBALS.G_ENTITY_LINE,
        p_entity_id                     =>      update_line.line_id,
        p_requesting_entity_code        =>      OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id          =>      update_line.line_id,
        p_request_type                  =>      OE_GLOBALS.G_CALCULATE_COMMITMENT,
        x_return_status                 =>      l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('old SP :'||update_line.unit_selling_price);
     oe_debug_pub.add('new SP :'||update_line.new_selling_price);
  END IF;

  -- BLANKETS: log request to update blanket amounts if price changes
  -- BUG 2746595, send currency code as request_unique_key1 parameter to
  -- process release request. This is required as 2 distinct requests need to
  -- be logged for currency updates.

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509'
     -- Bug 2739731 => do not log blanket requests for return lines
     AND update_line.line_category_code = 'ORDER'
     AND update_line.blanket_number IS NOT NULL
  THEN

       IF l_debug_level > 0 THEN
          oe_debug_pub.add('OEXVOPRB log blanket request');
          oe_debug_pub.add('old SP :'||update_line.unit_selling_price);
          oe_debug_pub.add('new SP :'||update_line.new_selling_price);
       END IF;

       OE_Order_Cache.Load_Order_Header(update_line.header_id);
--for bug 3108881
--request should be logged only for Sales order and not for quotes
        IF nvl(update_line.transaction_phase_code,'F') = 'F' THEN

	       OE_Delayed_Requests_Pvt.Log_Request
       		(p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
       		,p_entity_id                 => update_line.line_id
       		,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
       		,p_requesting_entity_id      => update_line.line_id
       		,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
       		-- Old values
       		,p_param1                    => update_line.blanket_number
       		,p_param2                    => update_line.blanket_line_number
       		,p_param3                    => update_line.ordered_quantity
       		,p_param4                    => update_line.order_quantity_uom
       		,p_param5                    => update_line.unit_selling_price
       		,p_param6                    => update_line.inventory_item_id
       		-- New values
       		,p_param11                   => update_line.blanket_number
       		,p_param12                   => update_line.blanket_line_number
       		,p_param13                   => update_line.ordered_quantity
       		,p_param14                   => update_line.order_quantity_uom
       		,p_param15                   => update_line.new_selling_price
       		,p_param16                   => update_line.inventory_item_id
       		 -- Other parameters
       		,p_param8                    => update_line.fulfilled_flag
       		,p_param9                    => update_line.line_set_id
       		,p_request_unique_key1       =>
        	                OE_Order_Cache.g_header_rec.transactional_curr_code
       		,x_return_status             => l_return_status
       		);
       		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       		   RAISE FND_API.G_EXC_ERROR;
       		END IF;

       		IF update_line.line_set_id IS NOT NULL THEN
         		OE_Delayed_Requests_Pvt.Log_Request
         		  (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
         		  ,p_entity_id                 => update_line.line_set_id
         		  ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
         		  ,p_requesting_entity_id      => update_line.line_id
         		  ,p_request_type              => 'VALIDATE_RELEASE_SHIPMENTS'
         		  ,p_request_unique_key1       => update_line.blanket_number
         		  ,p_request_unique_key2       => update_line.blanket_line_number
         		  ,p_param1                    =>
                        	OE_Order_Cache.g_header_rec.transactional_curr_code
         		  ,x_return_status             => l_return_status
         		  );
           		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           		   RAISE FND_API.G_EXC_ERROR;
           		END IF;
       		END IF;
	END IF;--End for quote/order check
   END IF; -- End for log blanket request

--Bug 4332307 Logging Margin Hold delayed request
  IF update_line.booked_flag = 'Y' THEN
     IF OE_FEATURES_PVT.Is_Margin_Avail THEN
        IF Oe_Sys_Parameters.Value('COMPUTE_MARGIN') <> 'N' Then
           l_log_mrg_hold_req := 'Y';
           l_header_id := update_line.header_id;
        END IF;
     END IF;
  END IF;
--Bug 4332307

end loop;

     --bug 4332307
      IF l_log_mrg_hold_req = 'Y' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR MARGIN HOLD FOR BOOKED HEADER_ID:'||l_header_id ) ;
         END IF;
         oe_delayed_requests_pvt.log_request(
                     p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                     p_entity_id              => l_header_id,

                     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                     p_requesting_entity_id   => l_header_id,

                     p_request_type           => 'MARGIN_HOLD',
                     x_return_status          => l_return_status);
      END IF;
      --bug 4332307


IF (G_PASS_ALL_LINES in ('N', 'R')) THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DID NOT PASS ALL LINES , LOG REQUEST' ) ;
  END IF;
  BEGIN
    SELECT processed_flag
    INTO l_order_adj_changed_flag
    FROM qp_preq_lines_tmp
    WHERE line_type_code='ORDER' and price_flag='Y';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER ADJ CHANGED:'||L_ORDER_ADJ_CHANGED_FLAG ) ;
    END IF;
    IF (l_order_adj_changed_flag = 'C') THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOGGING REQUEST TO UPDATE ALL LINES FOR HEADER LEVEL ADJUSTMENT.' , 1 ) ;
      END IF;
      OE_DELAYED_REQUESTS_PVT.LOG_REQUEST(
                        p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                        p_entity_id              =>  oe_order_pub.g_hdr.header_id,
                        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                        p_requesting_entity_id   =>  oe_order_pub.g_hdr.header_id,
                        p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
                        x_return_status          => l_return_status);

    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NO SUMMARY LINE WITH PRICE FLAG OF Y' ) ;
   END IF;
   NULL;
  WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PROBLEM?'||SQLERRM ) ;
   END IF;
  END;
END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER LOG_REQUEST' , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'WRONG IN LOG_REQUEST'||SQLERRM , 1 ) ;
   END IF;
   raise fnd_api.g_exc_error;
End LOG_REQUEST;

PROCEDURE UPDATE_ORDER_LINES(
   px_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE
, x_num_changed_lines OUT NOCOPY NUMBER
,p_write_to_db BOOLEAN DEFAULT FALSE
)
IS
l_return_status varchar2(1);

DEADLOCK_DETECTED EXCEPTION;
PRAGMA EXCEPTION_INIT(DEADLOCK_DETECTED, -60);

/*
Cursor get_lock_info is
Select Waiting_Session,Holding_session,lock_type,MODE_HELD,MODE_REQUESTED,LOCK_ID1,LOCK_ID2
From dba_waiters;
*/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
--RT{
 IF nvl(G_PRICING_EVENT,';xx-') = 'RETROBILL' THEN
   oe_debug_pub.add('Calling update retrobill lines');
   LOG_REQUEST(px_line_tbl);
   Oe_Retrobill_Pvt.UPDATE_RETROBILL_LINES(G_RETROBILL_OPERATION);
 ELSE --RT
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ENTERING OE_ORDER_PRICE_PVT.UPDATE_ORDER_LINES' ) ;
  END IF;

  SECURITY_AND_GLOBAL_PICTURE(px_line_tbl,p_write_to_db);

  LOG_REQUEST(px_line_tbl);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' BEFORE UPDATING ORDER LINES' , 3 ) ;
  END IF;
  UPDATE OE_ORDER_LINES_all l
  SET (UNIT_SELLING_PRICE
    , UNIT_LIST_PRICE
    ,UNIT_SELLING_PRICE_PER_PQTY
    ,UNIT_LIST_PRICE_PER_PQTY
    , PRICING_QUANTITY
    , PRICING_QUANTITY_UOM
    , PRICE_LIST_ID
    , PRICE_REQUEST_CODE
    , UNIT_LIST_PERCENT
    , UNIT_PERCENT_BASE_PRICE
    , UNIT_SELLING_PERCENT
    , LOCK_CONTROL
    , LAST_UPDATE_DATE                     -- Added WHO columns for the bug 3105197
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN)
  =
     (select
      nvl(lines.order_uom_selling_price, lines.ADJUSTED_UNIT_PRICE*nvl(lines.priced_quantity,l.ordered_quantity)/l.ordered_quantity)
    , nvl(lines.line_unit_price, lines.UNIT_PRICE*nvl(lines.priced_quantity,l.ordered_quantity)/l.ordered_quantity)
    , lines.ADJUSTED_UNIT_PRICE
    , lines.UNIT_PRICE
    , decode(lines.priced_quantity,-99999,l.ordered_quantity,lines.priced_quantity)
    , decode(lines.priced_quantity,-99999,l.order_quantity_uom,lines.priced_uom_code)
    , decode(lines.price_list_header_id,-9999,NULL,lines.price_list_header_id) --Bug#2830609
    , lines.price_request_code
    , nvl(lines.percent_price, NULL)
    , nvl(lines.parent_price, NULL)
    , decode(lines.parent_price, NULL, 0, 0, 0,
           lines.adjusted_unit_price/lines.parent_price)
    , l.lock_control + 1
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.LOGIN_ID
   from qp_preq_lines_tmp lines
       where lines.line_id=l.line_id
       and l.open_flag <> 'N'
       and lines.line_type_code='LINE'
       and lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
       and lines.process_status <> 'NOT_VALID'
     )
where
--l.header_id=oe_order_pub.g_hdr.header_id
--and
l.ordered_quantity <> 0
and l.open_flag <> 'N'
and l.line_id in (select line_id from qp_preq_lines_tmp lines
                  where
  lines.pricing_status_code in
             (QP_PREQ_GRP.G_STATUS_UPDATED,
             QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
 and lines.process_status <> 'NOT_VALID'
                  and
              lines.line_type_code='LINE');
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' LEAVING UPDATE_ORDER_LINES:'||SQL%ROWCOUNT , 3 ) ;
END IF;
x_num_changed_lines := SQL%ROWCOUNT;
END IF; --RT
EXCEPTION
  WHEN DEADLOCK_DETECTED THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'WRONG IN UPDATE_ORDER_LINES'||SQLERRM , 1 ) ;
   END IF;
   /*
   For i in get_lock_info Loop
   oe_debug_pub.add('Waiting_Session:'||i.waiting_Session||' Holding_session:'||i.Holding_session);
   oe_debug_pub.add('Lock_type:'||i.lock_type||' MODE_HELD:'||i.MODE_HELD||' MODE_REQUESTED'||i.MODE_REQUESTED);
   oe_debug_pub.add('Lock_ID1:'||i.Lock_ID1||' Lock_ID2:'||i.Lock_ID2);
   End Loop;
   */
   raise fnd_api.g_exc_unexpected_error;
  WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'WRONG IN UPDATE_ORDER_LINES'||SQLERRM , 1 ) ;
   END IF;
   raise fnd_api.g_exc_unexpected_error;
End UPDATE_ORDER_LINES;

--bug 3882620 Changed the Signature for the procedure Delete_dependents
PROCEDURE DELETE_DEPENDENTS(
  p_adj_id_tbl  IN OUT NOCOPY NUMBER_TYPE,
  p_header_id_tbl           IN OUT NOCOPY NUMBER_TYPE,
  p_line_id_tbl             IN OUT NOCOPY NUMBER_TYPE,
  p_list_line_id_tbl        IN OUT NOCOPY NUMBER_TYPE,
  p_list_header_id_tbl      IN OUT NOCOPY NUMBER_TYPE,
  p_list_line_type_code_tbl IN OUT NOCOPY VARCHAR_TYPE,
  p_applied_flag_tbl        IN OUT NOCOPY VARCHAR_TYPE,
  p_adjusted_amount_tbl     IN OUT NOCOPY NUMBER_TYPE
) IS
i NUMBER;
l_Line_Adj_rec    OE_Order_PUB.Line_Adj_Rec_Type;
l_Header_Adj_rec  OE_Order_PUB.Header_Adj_Rec_Type; -- bug 8415941
l_return_status         VARCHAR2(30);
l_index    NUMBER;
l_booked_flag  varchar2(1) := oe_order_cache.g_header_rec.booked_flag;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('l_booked_flag in delete dependents = '||l_booked_flag);
  END IF;
  If p_adj_id_tbl.count > 0 Then
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
    --IF l_booked_flag = 'Y' THEN
     --IF oe_adv_price_pvt.check_notify_OC then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Delete adjustments notify to OC');
      END IF;
     i := p_adj_id_tbl.first;
     while i is not null loop
      IF (p_line_id_tbl(i) is NOT NULL) THEN  -- Line Level Adjustment 8415941
               IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Line Level Adjustment 8415941 ');
               END IF;
       l_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       l_Line_Adj_rec.price_adjustment_id := p_adj_id_tbl(i);
       --bug 3882620
       l_Line_Adj_rec.header_id           := p_header_id_tbl(i);
       l_Line_Adj_rec.line_id             := p_line_id_tbl(i);
       l_Line_Adj_rec.list_line_id        := p_list_line_id_tbl(i);
       l_Line_Adj_rec.list_header_id      := p_list_header_id_tbl(i);
       l_Line_Adj_rec.list_line_type_code := p_list_line_type_code_tbl(i);
       l_Line_Adj_rec.applied_flag        := p_applied_flag_tbl(i);
       l_Line_Adj_rec.adjusted_amount     := p_adjusted_amount_tbl(i);
       l_Line_Adj_rec.last_update_date    := sysdate;
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('header_id:'||l_Line_Adj_rec.header_id||'line_id:'|| l_Line_Adj_rec.line_id);
         oe_debug_pub.add('list_line_id:'||l_Line_Adj_rec.list_line_id||'list_header_id:'||l_Line_Adj_rec.list_header_id);
         oe_debug_pub.add('last_update_date:'||l_Line_Adj_rec.last_update_date);
       END IF;
       --bug 3882620
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_line_adj_rec,
                    p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                    p_old_line_adj_rec =>l_line_adj_rec,
                    x_index => l_index,
                    x_return_status => l_return_status);
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_ORDER_PRICE_PVT.DELETE_DEPENDENTS IS: ' || L_RETURN_STATUS ) ;
            END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
               oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.DELETE_DEPENDENTS', 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_ORDER_PRICE_PVT.DELETE_DEPENDENTS' ) ;
               oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.DELETE_DEPENDENTS', 1 ) ;
           END IF;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       ELSE -- Header Level Adjustment
                       IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Header Level Adjustment 8415941 ');
                        END IF;

                   l_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
                   l_Header_Adj_rec.price_adjustment_id := p_adj_id_tbl(i);
                   l_Header_Adj_rec.header_id           := p_header_id_tbl(i);
                   l_Header_Adj_rec.list_line_id        := p_list_line_id_tbl(i);
                   l_Header_Adj_rec.list_header_id      := p_list_header_id_tbl(i);
                   l_Header_Adj_rec.list_line_type_code := p_list_line_type_code_tbl(i);
                   l_Header_Adj_rec.applied_flag        := p_applied_flag_tbl(i);
                   l_Header_Adj_rec.adjusted_amount     := p_adjusted_amount_tbl(i);
                   l_Header_Adj_rec.last_update_date    := sysdate;


                   OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                              p_hdr_adj_rec =>l_header_adj_rec,
                              p_hdr_adj_id => l_header_adj_rec.price_adjustment_id,
                              p_old_hdr_adj_rec =>l_header_adj_rec,
                              x_index => l_index,
                              x_return_status => l_return_status);
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM Header Level Adj: ' || L_RETURN_STATUS ) ;
                   END IF;
                   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'Delete - UNEXPECTED ERROR' ) ;
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'Delete -Error' ) ;
                       END IF;
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

                 END IF; -- End Line Adjustment
       i := p_adj_id_tbl.next(i);
     end loop;
    --END IF;
   --END IF;
  END IF;

    FORALL i IN p_adj_id_tbl.FIRST..p_adj_id_tbl.LAST
    DELETE FROM OE_PRICE_ADJ_ATTRIBS  WHERE price_adjustment_id  = p_adj_id_tbl(i);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' DELETED '||SQL%ROWCOUNT||' ATTRIBS' , 3 ) ;
    END IF;

    FORALL i IN p_adj_id_tbl.FIRST..p_adj_id_tbl.LAST
    DELETE FROM OE_PRICE_ADJ_ASSOCS WHERE price_adjustment_id = p_adj_id_tbl(i);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' DELETED '||SQL%ROWCOUNT||' ASSOCS' , 3 ) ;
    END IF;

    FORALL i IN p_adj_id_tbl.FIRST..p_adj_id_tbl.LAST
    DELETE FROM OE_PRICE_ADJ_ASSOCS WHERE rltd_price_adj_id = p_adj_id_tbl(i);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' DELETED '||SQL%ROWCOUNT||' RLTD ASSOCS' , 3 ) ;
    END IF;

    p_adj_id_tbl.delete;
  End If;

END DELETE_DEPENDENTS;

---bug 3740009
PROCEDURE DELETE_HDR_ADJS( p_pricing_events varchar2
                          ,p_hdr_line_id    number
                          ,p_hdr_line_index number
                          ,p_hdr_price_flag varchar2
                          ,p_hdr_pricing_status_code varchar2)

IS

l_adj_id_tbl Number_Type;
--bug 3882620
l_line_id_tbl Number_Type;
l_list_line_type_code_tbl Varchar_Type;
l_header_id_tbl Number_Type;
l_applied_flag_tbl Varchar_Type;
l_list_header_id_tbl Number_Type;
l_adjusted_amount_tbl Number_Type;
l_list_line_id_tbl Number_Type;
--bug 3882620
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF p_hdr_price_flag in ('Y', 'P') AND p_hdr_pricing_status_code IN
                                     (QP_PREQ_PUB.G_STATUS_UPDATED,
                                      QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                     )
   THEN
     DELETE FROM OE_PRICE_ADJUSTMENTS
     WHERE HEADER_ID=oe_order_pub.g_hdr.header_id
     AND LINE_ID IS NULL
     AND LIST_LINE_TYPE_CODE NOT IN ('TAX')
     AND NVL(UPDATED_FLAG, 'N')='N'
     AND PRICING_PHASE_ID IN (select b.pricing_phase_id
                              from qp_event_phases a,
                                   qp_pricing_phases b
                  where instr(p_pricing_events, a.pricing_event_code||',') > 0
                    and   b.pricing_phase_id   = a.pricing_phase_id
                    and   nvl(b.user_freeze_override_flag,freeze_override_flag)
                        = decode(p_hdr_price_flag, 'Y', nvl(b.user_freeze_override_flag,b.freeze_override_flag), 'P', 'Y'))
     AND HEADER_ID = p_hdr_line_id
     AND list_line_id not in (select list_line_id from qp_ldets_v ld
                              where ld.process_code in (QP_PREQ_GRP.G_STATUS_NEW,  --bug 4190357
                                                        QP_PREQ_GRP.G_STATUS_UPDATED,
                                                        QP_PREQ_GRP.G_STATUS_UNCHANGED)
                                and ld.line_index = p_hdr_line_index
                                and p_hdr_line_id = oe_order_pub.g_hdr.header_id)
     returning price_adjustment_id,
               header_id,
               line_id,
               list_line_id,
               list_header_id,
               list_line_type_code,
               applied_flag,
               adjusted_amount
     bulk collect into
               l_adj_id_tbl,
               l_header_id_tbl,
               l_line_id_tbl,
               l_list_line_id_tbl,
               l_list_header_id_tbl,
               l_list_line_type_code_tbl,
               l_applied_flag_tbl,
               l_adjusted_amount_tbl;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETED '||SQL%ROWCOUNT||' HEADER LEVEL ADJUSTMENTS/CHARGES' , 3 ) ;
     END IF;
     DELETE_DEPENDENTS(l_adj_id_tbl,l_header_id_tbl,l_line_id_tbl,l_list_line_id_tbl,l_list_header_id_tbl,l_list_line_type_code_tbl,l_applied_flag_tbl,l_adjusted_amount_tbl);
   END IF;
END DELETE_HDR_ADJS;

PROCEDURE DELETE_LINES_ADJS(p_pricing_events IN varchar2)

IS

l_line_type_code varchar2(6);
cursor updated_order_lines(l_line_type_code in varchar2) is
select line_id, price_flag, line_index from qp_preq_lines_tmp
where price_flag IN ('Y','P')
and line_type_code = l_line_type_code
and process_status <> 'NOT_VALID'
and pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED
                           , QP_PREQ_PUB.G_STATUS_GSA_VIOLATION);

l_adj_id_tbl Number_Type;
--bug 3882620
l_line_id_tbl Number_Type;
l_list_line_type_code_tbl Varchar_Type;
l_header_id_tbl Number_Type;
l_applied_flag_tbl Varchar_Type;
l_list_header_id_tbl Number_Type;
l_adjusted_amount_tbl Number_Type;
l_list_line_id_tbl Number_Type;
--bug 3882620
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

      l_line_type_code := 'LINE';
      For one_line in updated_order_lines(l_line_type_code) loop
        DELETE /*+ index (adj oe_price_adjustments_n2) */
        FROM OE_PRICE_ADJUSTMENTS adj
        WHERE --HEADER_ID=oe_order_pub.g_hdr.header_id
          LINE_ID = one_line.line_id
          AND LIST_LINE_TYPE_CODE NOT IN ('TAX','IUE') --bug 2858712
          AND NVL(UPDATED_FLAG, 'N')='N'
          AND PRICING_PHASE_ID IN (select b.pricing_phase_id
                            from qp_event_phases a,
                                 qp_pricing_phases b
                            where instr(p_pricing_events, a.pricing_event_code||',') > 0
                            and   b.pricing_phase_id   = a.pricing_phase_id
                            and   nvl(b.user_freeze_override_flag,freeze_override_flag)
                                = decode(one_line.price_flag, 'Y', nvl(b.user_freeze_override_flag,b.freeze_override_flag), 'P', 'Y'))
          AND list_line_id not in (select list_line_id from qp_ldets_v ld
                                   where ld. process_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                                              QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                                              QP_PREQ_PUB.G_STATUS_NEW)
                                   and ld.line_index = one_line.line_index
                                   and (ld.applied_flag = decode(one_line.price_flag, 'Y', 'Y', 'P', ld.applied_flag)
                                        OR
                                        ((nvl(ld.applied_flag,'N') = decode(one_line.price_flag, 'Y', 'N', 'P', nvl(ld.applied_flag,'N'))
                                         AND
                                         nvl(ld.line_detail_type_code,'x') = decode(one_line.price_flag, 'Y', 'CHILD_DETAIL_LINE', 'P', nvl(ld.line_detail_type_code,'x'))
                                        ))
                                   ))
          returning price_adjustment_id,
                    header_id,
                    line_id,
                    list_line_id,
                    list_header_id,
                    list_line_type_code,
                    applied_flag,
                    adjusted_amount
          bulk collect into
                    l_adj_id_tbl,
                    l_header_id_tbl,
                    l_line_id_tbl,
                    l_list_line_id_tbl,
                    l_list_header_id_tbl,
                    l_list_line_type_code_tbl,
                    l_applied_flag_tbl,
                    l_adjusted_amount_tbl;

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DELETED '||SQL%ROWCOUNT||' LINE LEVEL ADJUSTMENTS/CHARGES FOR LINE:'||ONE_LINE.LINE_ID , 3 ) ;
          END IF;
          DELETE_DEPENDENTS(l_adj_id_tbl,l_header_id_tbl,l_line_id_tbl,l_list_line_id_tbl,l_list_header_id_tbl,l_list_line_type_code_tbl,l_applied_flag_tbl,l_adjusted_amount_tbl);
        END LOOP;

END DELETE_LINES_ADJS;

PROCEDURE DELETE_ONE_LINE_ADJS(p_line_id in number, p_pricing_events IN varchar2)

IS

l_line_id Number;
l_price_flag Varchar2(1);
l_adj_id_tbl Number_Type;
--bug 3882620
l_line_id_tbl Number_Type;
l_list_line_type_code_tbl Varchar_Type;
l_header_id_tbl Number_Type;
l_applied_flag_tbl Varchar_Type;
l_list_header_id_tbl Number_Type;
l_adjusted_amount_tbl Number_Type;
l_list_line_id_tbl Number_Type;
--bug 3882620
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   select line_id,
          price_flag
   into   l_line_id,
          l_price_flag
   from   qp_preq_lines_tmp
   where  line_id = p_line_id
     and  line_type_code = 'LINE'
     and  price_flag in ('Y', 'P')
     and process_status <> 'NOT_VALID'
     and pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                 QP_PREQ_PUB.G_STATUS_GSA_VIOLATION);

   DELETE FROM OE_PRICE_ADJUSTMENTS
   WHERE HEADER_ID=oe_order_pub.g_hdr.header_id
   AND LINE_ID=p_line_id
   AND NVL(UPDATED_FLAG, 'N')='N'
   AND PRICING_PHASE_ID IN (select b.pricing_phase_id
                            from qp_event_phases a,
                                 qp_pricing_phases b
                            where instr(p_pricing_events, a.pricing_event_code||',') > 0
                            and   b.pricing_phase_id   = a.pricing_phase_id
                            and   nvl(b.user_freeze_override_flag,b.freeze_override_flag)
                                = decode(l_price_flag, 'Y', nvl(b.user_freeze_override_flag,b.freeze_override_flag), 'P', 'Y'))
   AND LINE_ID = p_line_id
   AND LIST_LINE_TYPE_CODE NOT IN ('TAX','IUE') --bug 2858712
   AND list_line_id not in (select list_line_id
                            from qp_ldets_v ld
                            where ld.process_code in
                                     (QP_PREQ_GRP.G_STATUS_UPDATED,
                                      QP_PREQ_GRP.G_STATUS_UNCHANGED,
                                      QP_PREQ_PUB.G_STATUS_NEW)
                              and (ld.applied_flag = 'Y'
                               OR
                                (nvl(ld.applied_flag,'N') = 'N'
                                  AND
                                 nvl(ld.line_detail_type_code,'x') = 'CHILD_DETAIL_LINE'
                                 )
                               )
                           )
    returning price_adjustment_id,
              header_id,
              line_id,
              list_line_id,
              list_header_id,
              list_line_type_code,
              applied_flag,
              adjusted_amount
    bulk collect into
              l_adj_id_tbl,
              l_header_id_tbl,
              l_line_id_tbl,
              l_list_line_id_tbl,
              l_list_header_id_tbl,
              l_list_line_type_code_tbl,
              l_applied_flag_tbl,
              l_adjusted_amount_tbl;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DELETED '||SQL%ROWCOUNT||' LINE LEVEL ADJUSTMENTS/CHARGES' , 3 ) ;
    END IF;
    DELETE_DEPENDENTS(l_adj_id_tbl,l_header_id_tbl,l_line_id_tbl,l_list_line_id_tbl,l_list_header_id_tbl,l_list_line_type_code_tbl,l_applied_flag_tbl,l_adjusted_amount_tbl);

END DELETE_ONE_LINE_ADJS;
---bug 3740009


--bug 3836854
PROCEDURE update_adj(
                      p_price_adjustment_id IN NUMBER
                     ,p_line_detail_index IN NUMBER
                     ,px_debug_upd_adj_tbl OUT NOCOPY NUMBER_TYPE
                    )
IS

  l_price_adjustment_id NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('entering procedure update_adj');
      oe_debug_pub.add('p_price_adjustment_id : '||p_price_adjustment_id);
      oe_debug_pub.add('p_line_detail_index : '||p_line_detail_index);
    END IF;

    --bug 5497035
    BEGIN

      SELECT price_adjustment_id
      INTO   l_price_adjustment_id
      FROM   oe_price_adjustments
      WHERE  price_adjustment_id = p_price_adjustment_id
      FOR UPDATE NOWAIT;

      IF l_debug_level > 0 Then
         oe_Debug_pub.add('Adjustment row successfully locked');
      END IF;

    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('in lock record exception, someone else working on the row');
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;

     WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('no_data_found, record lock exception');
        END IF;
      --bug 5709185 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('record lock exception, others');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    --bug 5497035

    UPDATE OE_PRICE_ADJUSTMENTS adj
      SET ( operand
        , operand_per_pqty
        , adjusted_amount
        , adjusted_amount_per_pqty
        , arithmetic_operator
        , pricing_phase_id
        , pricing_group_sequence
        , automatic_flag
        , list_line_type_code
        --, applied_flag
        , modified_from
        , modified_to
        , update_allowed
        --, modifier_mechanism_type_code
        --, updated_flag
        , charge_type_code
        , charge_subtype_code
        , range_break_quantity
        , accrual_conversion_rate
        , accrual_flag
        , list_line_no
        --, source_system_code
        , benefit_qty
        , benefit_uom_code
        , print_on_invoice_flag
        , expiration_date
        , rebate_transaction_type_code
        --, rebate_transaction_reference
        --, rebate_payment_system_code
        --, redeemed_date
        --, redeemed_Flag
        , modifier_level_code
        , price_break_type_code
        , substitution_attribute
        , proration_type_code
        , include_on_returns_flag
        , lock_control
        --bug#7369643
	--This code is added to update the last update information in who columns
	        , LAST_UPDATE_DATE
	        , LAST_UPDATED_BY
	        , LAST_UPDATE_LOGIN
        --bug#7369643
        )
    =
       (select
         ldets.order_qty_operand
       , ldets.operand_value
       , ldets.order_qty_adj_amt
       , ldets.adjustment_amount
       , ldets.operand_calculation_code
       , ldets.pricing_phase_id
       , ldets.pricing_group_sequence
       , ldets.automatic_flag
       , ldets.list_line_type_code
       --, ldets.applied_flag
       , decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute,
'IUE', to_char(ldets.inventory_item_id), NULL)
       , decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to,
'IUE',to_char(ldets.related_item_id), NULL)
        , ldets.override_flag
        --, modifier_mechanism_type_code
        --, ldets.updated_flag
        , ldets.charge_type_code
        , ldets.charge_subtype_code
        , ldets.line_quantity  --range_break_quantity (?)
        , ldets.accrual_conversion_rate
        , ldets.accrual_flag
        , ldets.list_line_no
        --, source_system_code
        , ldets.benefit_qty
        , ldets.benefit_uom_code
        , ldets.print_on_invoice_flag
        , ldets.expiration_date
        , ldets.rebate_transaction_type_code
        --, rebate_transaction_reference
        --, rebate_payment_system_code
        --, redeemed_date
        --, redeemed_Flag
        , ldets.modifier_level_code
        , ldets.price_break_type_code
        , ldets.substitution_attribute
        , ldets.proration_type_code
        , ldets.include_on_returns_flag
        , adj.lock_control + 1
        --bug#7369643
	--This code is added to update the last update information in who columns
	        , sysdate
	        , fnd_global.user_id
	        , fnd_global.LOGIN_ID
        --bug#7369643
       from
         QP_LDETS_v ldets
       where ldets.line_detail_index = p_line_detail_index
       )
    where adj.price_adjustment_id = p_price_adjustment_id
    returning adj.list_line_id bulk collect into px_debug_upd_adj_tbl;
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('exiting update_adj procedure');
    END IF;
END update_adj;
--bug 3836854

PROCEDURE REFRESH_ADJS(
   p_line_id IN NUMBER
,  p_pricing_events IN VARCHAR2
,  p_calculate_flag IN VARCHAR2
,  p_header_id IN Number default null
) IS
l_adjustment_count NUMBER:=0;

l_adj_id_tbl Number_Type;
l_debug_upd_order_adj_tbl Number_Type;
l_debug_upd_line_adj_tbl Number_Type;
l_line_detail_index_tbl Number_type;
i number;
l_pricing_events varchar2(40) := p_pricing_events||',';
l_stmt number:=0;
cursor del_attribs1 Is
Select /*+ ORDERED USE_NL(ADJ LDETS) index(QPLINES QP_PREQ_LINES_TMP_N2) index(ADJ OE_PRICE_ADJUSTMENTS_N2)*/
       adj.price_adjustment_id, ldets.line_detail_index
 From   QP_PREQ_LINES_TMP        QPLINES
       ,OE_PRICE_ADJUSTMENTS     ADJ
       ,QP_LDETS_V               LDETS
 Where LDETS.LIST_LINE_ID      = ADJ.LIST_LINE_ID
 AND   LDETS.LINE_INDEX        = QPLINES.LINE_INDEX
 AND   ADJ.PRICING_PHASE_ID in (select pricing_phase_id from qp_event_phases
 --                                where pricing_event_code = p_pricing_events)
 --changes to enable multiple events passed as a string
                where instr(l_pricing_events, pricing_event_code||',') > 0)
 AND   LDETS.PROCESS_CODE in (QP_PREQ_GRP.G_STATUS_UNCHANGED,
                              QP_PREQ_GRP.G_STATUS_UPDATED)
 AND   nvl(ADJ.updated_flag,'N') = 'N'
 AND   QPLINES.LINE_ID         = ADJ.LINE_ID
 AND   QPLINES.PROCESS_STATUS <> 'NOT_VALID'
 AND   QPLINES.LINE_TYPE_CODE  = 'LINE';

cursor del_attribs2(p_hdr_line_index in number, p_hdr_line_id in number) Is
Select ADJ.PRICE_ADJUSTMENT_ID, LDETS.LINE_DETAIL_INDEX
 From
        OE_PRICE_ADJUSTMENTS     ADJ
       ,QP_LDETS_V               LDETS
 Where LDETS.LIST_LINE_ID      = ADJ.LIST_LINE_ID
 AND   LDETS.LINE_INDEX        = p_hdr_line_index
 AND   ADJ.PRICING_PHASE_ID in (select pricing_phase_id from qp_event_phases
  --                                where pricing_event_code = p_pricing_events)
  --changes to enable multiple events passed as a string
                where instr(l_pricing_events, pricing_event_code||',') > 0)
 AND   LDETS.PROCESS_CODE in (QP_PREQ_GRP.G_STATUS_UNCHANGED,
                              QP_PREQ_GRP.G_STATUS_UPDATED)
 AND   nvl(ADJ.updated_flag,'N') = 'N'
 AND   ADJ.HEADER_ID         = p_hdr_line_id;

--pviprana: cursors retrieving the needed values from qp temp tables for debugging purpose *start*
cursor debug_updatable_order_adj is
       select ldets.list_line_id,
              ldets.adjustment_amount,
              ldets.order_qty_adj_amt,
              ldets.order_qty_operand,
              ldets.operand_calculation_code,
              ldets.operand_value,
              lines.priced_quantity,
              lines.line_quantity,
              ldets.pricing_phase_id,
              ldets.pricing_group_sequence,
              ldets.automatic_flag,
              ldets.list_line_type_code,
              ldets.applied_flag,
              ldets.substitution_attribute,
              ldets.inventory_item_id,
              ldets.substitution_value_to,
              ldets.related_item_id,
              ldets.override_flag,
              ldets.updated_flag,
              ldets.charge_type_code,
              ldets.charge_subtype_code,
              ldets.accrual_conversion_rate,
              ldets.accrual_flag,
              ldets.list_line_no,
              ldets.benefit_qty,
              ldets.benefit_uom_code,
              ldets.print_on_invoice_flag,
              ldets.expiration_date,
              ldets.rebate_transaction_type_code,
              ldets.modifier_level_code,
              ldets.price_break_type_code,
              ldets.proration_type_code,
              ldets.include_on_returns_flag,
              adj.lock_control + 1 adj_lock_control
       from OE_PRICE_ADJUSTMENTS adj
        ,  QP_LDETS_v ldets
        ,  QP_PREQ_LINES_TMP lines
       WHERE
        adj.header_id=oe_order_pub.g_hdr.header_id
        and lines.line_index = ldets.line_index
        and lines.process_status <> 'NOT_VALID'
        and ldets.list_line_id = adj.list_line_id
        and lines.line_type_code='ORDER' and lines.line_id=adj.header_id
        and ldets.process_code = QP_PREQ_GRP.G_STATUS_UPDATED;

cursor debug_updatable_line_adj is
       select ldets.list_line_id,
              ldets.adjustment_amount,
              ldets.order_qty_adj_amt,
              ldets.order_qty_operand,
              ldets.operand_calculation_code,
              ldets.operand_value,
              lines.priced_quantity,
              lines.line_quantity,
              ldets.pricing_phase_id,
              ldets.pricing_group_sequence,
              ldets.automatic_flag,
              ldets.list_line_type_code,
              ldets.applied_flag,
              ldets.substitution_attribute,
              ldets.inventory_item_id,
              ldets.substitution_value_to,
              ldets.related_item_id,
              ldets.override_flag,
              ldets.updated_flag,
              ldets.charge_type_code,
              ldets.charge_subtype_code,
              ldets.accrual_conversion_rate,
              ldets.accrual_flag,
              ldets.list_line_no,
              ldets.benefit_qty,
              ldets.benefit_uom_code,
              ldets.print_on_invoice_flag,
              ldets.expiration_date,
              ldets.rebate_transaction_type_code,
              ldets.modifier_level_code,
              ldets.price_break_type_code,
              ldets.proration_type_code,
              ldets.include_on_returns_flag,
              adj.lock_control + 1 adj_lock_control
        from OE_PRICE_ADJUSTMENTS adj
         ,    QP_LDETS_v ldets
         ,  QP_PREQ_LINES_TMP lines
        WHERE
        adj.header_id=oe_order_pub.g_hdr.header_id
        and lines.line_index = ldets.line_index
        and lines.process_status <> 'NOT_VALID'
        and ldets.list_line_id = adj.list_line_id
	and     lines.line_type_code='LINE' and lines.line_id=adj.line_id
        and ldets.process_code = QP_PREQ_GRP.G_STATUS_UPDATED;

--pviprana: cursors retrieving the needed values from qp temp tables for debugging purpose *end*

  l_booked_flag varchar2(1) := oe_order_cache.g_header_rec.booked_flag;

--bug 3836854
  Cursor upd_adj(l_line_type IN Varchar2) Is
  select ldets2.price_adjustment_id, ldets2.line_detail_index
  from   qp_ldets_v ldets2, QP_PREQ_LINES_TMP lines2
  where  ldets2.process_code=QP_PREQ_GRP.G_STATUS_UPDATED
    AND  lines2.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    and    lines2.process_status <> 'NOT_VALID'
    and    lines2.line_index = ldets2.line_index
    and    lines2.line_type_code = l_line_type
    AND (l_booked_flag = 'N' or ldets2.list_line_type_code<>'IUE');
--bug 3836854

---bug 3740009
l_hdr_price_flag  varchar2(1);
l_hdr_line_index  number;
l_hdr_line_id     number;
l_hdr_pricing_status_code VARCHAR2(30);
l_no_summary_line boolean := FALSE;
---bug 3740009
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE REFRESH_ADJS FOR LINE ID:'||P_LINE_ID|| ' EVENT:'||P_PRICING_EVENTS , 3 ) ;
   END IF;

---bug 3740009
 BEGIN
   select price_flag,
          line_index,
          line_id,
          pricing_status_code
   into   l_hdr_price_flag,
          l_hdr_line_index,
          l_hdr_line_id,
          l_hdr_pricing_status_code
   from
          qp_preq_lines_tmp
   where  line_type_code = 'ORDER'
     and  process_status <> 'NOT_VALID';
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     oe_debug_pub.add('No summary line');
     l_no_summary_line := TRUE;
 END;
---bug 3740009

--bug3654144
IF nvl(G_PRICING_EVENT,'x-c1') <> 'RETROBILL' THEN

IF (p_calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY) THEN
  IF (p_LINE_id IS NULL) THEN
---bug 3740009
     delete_hdr_adjs(l_pricing_events,l_hdr_line_id,l_hdr_line_index,l_hdr_price_flag,l_hdr_pricing_status_code);
     delete_lines_adjs(l_pricing_events);
---bug 3740009
   -- header level adjustments

  ELSE  -- (p_LINE_ID IS NOT NULL)

---bug 3740009
   delete_one_line_Adjs(p_line_id,l_pricing_events);
---bug 3740009

  END IF;  -- line_id is NULL
END IF;
--bug3654144 start
ELSE
   OE_RETROBILL_PVT.Update_Invalid_Diff_Adj;
END IF;
--bug3654144 end

l_stmt:=6;
--RT{
IF nvl(G_PRICING_EVENT,'x-c1') <> 'RETROBILL' THEN
    --pviprana: Debug messages to show the contents in the qp temp tables
    -- THE FOLLOWING CURSORS RETRIEVE ALL THE NEEDED VALUES FROM QP TEMP TABLES
    -- PLEASE PRINT THE NEEDED VALUES FOR DEBUGGING PURPOSES
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('UPDATABLE ORDER LEVEL ADJUSTMENTS :');
        FOR updble_order_adj IN debug_updatable_order_adj LOOP
	   oe_debug_pub.add( '************************************************************************');
	   oe_debug_pub.add('LIST_LINE_ID     : '||updble_order_adj.list_line_id);
	   oe_debug_pub.add('ORDER_QTY_ADJ_AMT: '||updble_order_adj.order_qty_adj_amt);
	   oe_debug_pub.add('ADJUSTMENT_AMOUNT: '||updble_order_adj.adjustment_amount);
	   oe_debug_pub.add( '************************************************************************');
	END LOOP;
	oe_debug_pub.add('UPDATABLE LINE LEVEL ADJUSTMENTS :');
	FOR updble_line_adj IN debug_updatable_line_adj LOOP
	   oe_debug_pub.add( '************************************************************************');
	   oe_debug_pub.add('LIST_LINE_ID     : '||updble_line_adj.list_line_id);
	   oe_debug_pub.add('ORDER_QTY_ADJ_AMT: '||updble_line_adj.order_qty_adj_amt);
	   oe_debug_pub.add('ADJUSTMENT_AMOUNT: '||updble_line_adj.adjustment_amount);
	   oe_debug_pub.add( '************************************************************************');
	END LOOP;
    END IF;

--bug 3836854
    for i in upd_adj('ORDER') loop
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('within upd_adj cursor for order');
        oe_debug_pub.add('l_hdr_price_flag : '||l_hdr_price_flag);
        IF l_no_summary_line THEN
          oe_debug_pub.add('l_no_summary_line : '|| 'TRUE');
        ELSE
          oe_debug_pub.add('l_no_summary_line : '|| 'FALSE');
        END IF;
      END IF;
      IF nvl(l_hdr_price_flag,'N') <> 'N' OR NOT l_no_summary_line THEN
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('within if l_hdr_price_flag');
        END IF;
        update_adj(i.price_adjustment_id, i.line_detail_index , l_debug_upd_order_adj_tbl);
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('after update_adj order');
        END IF;
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UPDATED '||SQL%ROWCOUNT||' ORDER LEVEL ADJUSTMENTS' , 3 ) ;
      END IF;
    end loop;

    for i in upd_adj('LINE') loop
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('within upd_adj cursor for line');
      END IF;
      update_adj(i.price_adjustment_id, i.line_detail_index, l_debug_upd_line_adj_tbl);
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('after update_adj for line');
        oe_debug_pub.add(  'UPDATED '||SQL%ROWCOUNT||' LINE LEVEL ADJUSTMENTS' , 3 ) ;
      END IF;
    end loop;
--bug 3836854

       --pviprana: printing the list_line_ids of order level adjustments that were updated
    IF l_debug_level > 0 THEN
       oe_debug_pub.add( '************************************************************************');
       oe_debug_pub.add('UPDATED ORDER LEVEL ADJ LIST LINE IDS ARE:');
       IF(l_debug_upd_order_adj_tbl.count > 0) THEN
          FOR i IN l_debug_upd_order_adj_tbl.FIRST..l_debug_upd_order_adj_tbl.LAST LOOP
            oe_debug_pub.add(l_debug_upd_order_adj_tbl(i));
  	  END LOOP;
       END IF;
       oe_debug_pub.add( '************************************************************************');
    END IF;


 IF l_debug_level  > 0 THEN
     --pviprana: printing the list_line_ids of line level adjustments that were updated
     oe_debug_pub.add( '************************************************************************');
     oe_debug_pub.add('UPDATED LINE LEVEL ADJ LIST LINE IDS ARE:');
     IF(l_debug_upd_line_adj_tbl.count > 0) THEN
        FOR i IN l_debug_upd_line_adj_tbl.FIRST..l_debug_upd_line_adj_tbl.LAST LOOP
	   oe_debug_pub.add(l_debug_upd_line_adj_tbl(i));
	END LOOP;
     END IF;
     oe_debug_pub.add( '************************************************************************');
 END IF;

IF (p_Calculate_Flag <> QP_PREQ_GRP.G_CALCULATE_ONLY) THEN
l_stmt:=7;
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
     OE_ADV_PRICE_PVT.Insert_Adj(p_header_id);
  ELSE
  INSERT INTO OE_PRICE_ADJUSTMENTS
    (       PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       HEADER_ID
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       AUTOMATIC_FLAG
    ,       PERCENT
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ORIG_SYS_DISCOUNT_REF
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,	  Arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
    ,	  LOCK_CONTROL
    )
    ( SELECT     /*+ ORDERED USE_NL(ldets lines qh) */
            oe_price_adjustments_s.nextval -- p_Line_Adj_rec.price_adjustment_id
    ,       sysdate --p_Line_Adj_rec.creation_date
    ,       fnd_global.user_id --p_Line_Adj_rec.created_by
    ,       sysdate --p_Line_Adj_rec.last_update_date
    ,       fnd_global.user_id --p_Line_Adj_rec.last_updated_by
    ,       fnd_global.login_id --p_Line_Adj_rec.last_update_login
    ,       NULL --p_Line_Adj_rec.program_application_id
    ,       NULL --p_Line_Adj_rec.program_id
    ,       NULL --p_Line_Adj_rec.program_update_date
    ,       NULL --p_Line_Adj_rec.request_id
    ,       oe_order_pub.g_hdr.header_id --p_Line_Adj_rec.header_id
    ,       NULL --p_Line_Adj_rec.discount_id
    ,       NULL  --p_Line_Adj_rec.discount_line_id
    ,       ldets.automatic_flag
    ,       NULL --p_Line_Adj_rec.percent
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,lines.line_id)
    ,       NULL --p_Line_Adj_rec.context
    ,       NULL --p_Line_Adj_rec.attribute1
    ,       NULL --p_Line_Adj_rec.attribute2
    ,       NULL --p_Line_Adj_rec.attribute3
    ,       NULL --p_Line_Adj_rec.attribute4
    ,       NULL --p_Line_Adj_rec.attribute5
    ,       NULL --p_Line_Adj_rec.attribute6
    ,       NULL --p_Line_Adj_rec.attribute7
    ,       NULL --p_Line_Adj_rec.attribute8
    ,       NULL --p_Line_Adj_rec.attribute9
    ,       NULL --p_Line_Adj_rec.attribute10
    ,       NULL --p_Line_Adj_rec.attribute11
    ,       NULL --p_Line_Adj_rec.attribute12
    ,       NULL --p_Line_Adj_rec.attribute13
    ,       NULL --p_Line_Adj_rec.attribute14
    ,       NULL --p_Line_Adj_rec.attribute15
    ,       NULL --p_Line_Adj_rec.orig_sys_discount_ref
    ,	  ldets.LIST_HEADER_ID
    ,	  ldets.LIST_LINE_ID
    ,	  ldets.LIST_LINE_TYPE_CODE
    ,	  NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,     decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL)
    ,	  'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,	  ldets.override_flag
    ,	  ldets.APPLIED_FLAG
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
    ,	  nvl(ldets.order_qty_operand, decode(ldets.operand_calculation_code,
             '%', ldets.operand_value,
             'LUMPSUM', ldets.operand_value,
             ldets.operand_value*lines.priced_quantity/lines.line_quantity))
    ,	  ldets.operand_calculation_code --p_Line_Adj_rec.arithmetic_operator
    ,	  NULl --p_line_Adj_rec.COST_ID
    ,	  NULL --p_line_Adj_rec.TAX_CODE
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  NULL --p_line_Adj_rec.INVOICED_FLAG
    ,	  NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,	  NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
    ,	  nvl(ldets.order_qty_adj_amt, ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))
    ,	  ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,	  ldets.CHARGE_TYPE_CODE
    ,	  ldets.CHARGE_SUBTYPE_CODE
    ,       ldets.list_line_no
    ,       qh.source_system_code
    ,       ldets.benefit_qty
    ,       ldets.benefit_uom_code
    ,       NULL --p_Line_Adj_rec.print_on_invoice_flag
    ,       ldets.expiration_date
    ,       ldets.rebate_transaction_type_code
    ,       NULL --p_Line_Adj_rec.rebate_transaction_reference
    ,       NULL --p_Line_Adj_rec.rebate_payment_system_code
    ,       NULL --p_Line_Adj_rec.redeemed_date
    ,       NULL --p_Line_Adj_rec.redeemed_flag
    ,       ldets.accrual_flag
    ,       ldets.line_quantity  --p_Line_Adj_rec.range_break_quantity
    ,       ldets.accrual_conversion_rate
    ,       ldets.pricing_group_sequence
    ,       ldets.modifier_level_code
    ,       ldets.price_break_type_code
    ,       ldets.substitution_attribute
    ,       ldets.proration_type_code
    ,       NULL --p_Line_Adj_rec.credit_or_charge_flag
    ,       ldets.include_on_returns_flag
    ,       NULL -- p_Line_Adj_rec.ac_context
    ,       NULL -- p_Line_Adj_rec.ac_attribute1
    ,       NULL -- p_Line_Adj_rec.ac_attribute2
    ,       NULL -- p_Line_Adj_rec.ac_attribute3
    ,       NULL -- p_Line_Adj_rec.ac_attribute4
    ,       NULL -- p_Line_Adj_rec.ac_attribute5
    ,       NULL -- p_Line_Adj_rec.ac_attribute6
    ,       NULL -- p_Line_Adj_rec.ac_attribute7
    ,       NULL -- p_Line_Adj_rec.ac_attribute8
    ,       NULL -- p_Line_Adj_rec.ac_attribute9
    ,       NULL -- p_Line_Adj_rec.ac_attribute10
    ,       NULL -- p_Line_Adj_rec.ac_attribute11
    ,       NULL -- p_Line_Adj_rec.ac_attribute12
    ,       NULL -- p_Line_Adj_rec.ac_attribute13
    ,       NULL -- p_Line_Adj_rec.ac_attribute14
    ,       NULL -- p_Line_Adj_rec.ac_attribute15
    ,       ldets.OPERAND_value
    ,       ldets.adjustment_amount
    ,       1
    FROM
         QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
    WHERE
         ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    --AND  ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND  nvl(ldets.automatic_flag,'N') = 'Y'
     --     or
     --     (ldets.list_line_type_code = 'FREIGHT_CHARGE'))
    AND ldets.created_from_list_type_code not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'
    AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE')
  );


IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' ADJUSTMENTS' , 3 ) ;
END IF;

/*Insert ASSO for header level adj
 * Comment out--Not possible to have header level adjustments with associations
        INSERT INTO OE_PRICE_ADJ_ASSOCS
        (       PRICE_ADJUSTMENT_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICE_ADJ_ASSOC_ID
                ,LINE_ID
                ,RLTD_PRICE_ADJ_ID
                ,LOCK_CONTROL
        )
        (SELECT  *+ ORDERED USE_NL(ADJ RADJ) *
                adj.price_adjustment_id
                ,sysdate  --p_Line_Adj_Assoc_Rec.creation_date
                ,fnd_global.user_id --p_Line_Adj_Assoc_Rec.CREATED_BY
                ,sysdate  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_DATE
                ,fnd_global.user_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATED_BY
                ,fnd_global.login_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_LOGIN
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE
                ,NULL  --p_Line_Adj_Assoc_Rec.REQUEST_ID
                ,OE_PRICE_ADJ_ASSOCS_S.nextval
                ,ADJ.LINE_ID
                ,RADJ.PRICE_ADJUSTMENT_ID
                ,1
        FROM  QP_PREQ_RLTD_LINES_TMP   RLTD ,
              OE_PRICE_ADJUSTMENTS ADJ,
              OE_PRICE_ADJUSTMENTS RADJ,
              QP_PREQ_LINES_TMP QPL
       WHERE
              ADJ.HEADER_ID = RLTD.LINE_INDEX                   AND
              ADJ.LIST_LINE_ID  = RLTD.LIST_LINE_ID             AND
              RADJ.HEADER_ID =    RLTD.RELATED_LINE_INDEX       AND
              RADJ.LIST_LINE_ID  =    RLTD.RELATED_LIST_LINE_ID AND
              RADJ.HEADER_ID = ADJ.HEADER_ID                    AND
              RLTD.PRICING_STATUS_CODE = 'N'                    AND
              QPL.LINE_INDEX = RLTD.LINE_INDEX                  AND
              QPL.LINE_TYPE_CODE = 'ORDER');
*/
l_stmt:=8;
 INSERT INTO OE_PRICE_ADJ_ASSOCS
        (       PRICE_ADJUSTMENT_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICE_ADJ_ASSOC_ID
                ,LINE_ID
                ,RLTD_PRICE_ADJ_ID
                ,LOCK_CONTROL
        )
        (SELECT  /*+ ORDERED USE_NL(QPL ADJ RADJ) */
                 adj.price_adjustment_id
                ,sysdate  --p_Line_Adj_Assoc_Rec.creation_date
                ,fnd_global.user_id --p_Line_Adj_Assoc_Rec.CREATED_BY
                ,sysdate  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_DATE
                ,fnd_global.user_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATED_BY
                ,fnd_global.login_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_LOGIN
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE
                ,NULL  --p_Line_Adj_Assoc_Rec.REQUEST_ID
                ,OE_PRICE_ADJ_ASSOCS_S.nextval
                ,ADJ.LINE_ID
                ,RADJ.PRICE_ADJUSTMENT_ID
                ,1
        FROM
              QP_PREQ_RLTD_LINES_TMP RLTD,
              QP_PREQ_LINES_TMP QPL,
              OE_PRICE_ADJUSTMENTS ADJ,
              OE_PRICE_ADJUSTMENTS RADJ
        WHERE QPL.LINE_INDEX = RLTD.LINE_INDEX              AND
              QPL.LINE_ID = ADJ.LINE_ID                     AND
              QPL.LINE_TYPE_CODE = 'LINE'                   AND
              QPL.PROCESS_STATUS <> 'NOT_VALID'             AND
              RLTD.LIST_LINE_ID = ADJ.LIST_LINE_ID          AND
              RLTD.RELATED_LINE_INDEX = QPL.LINE_INDEX      AND
              RLTD.RELATED_LIST_LINE_ID = RADJ.LIST_LINE_ID AND
              ADJ.LINE_ID = RADJ.LINE_ID                    AND
              RADJ.PRICE_ADJUSTMENT_ID
                NOT IN (SELECT RLTD_PRICE_ADJ_ID
                       FROM   OE_PRICE_ADJ_ASSOCS
                       WHERE PRICE_ADJUSTMENT_ID = ADJ.PRICE_ADJUSTMENT_ID ) AND
              RLTD.PRICING_STATUS_CODE = 'N');


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' PRICE ADJ ASSOCS' , 3 ) ;
   END IF;

  End If;  -- insert_adj

l_adj_id_tbl.delete;

open del_attribs1;
fetch del_attribs1 Bulk Collect into l_adj_id_tbl, l_line_detail_index_tbl;

If l_adj_id_tbl.count > 0 Then
l_stmt:=9;
 FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
 DELETE FROM OE_PRICE_ADJ_ATTRIBS  WHERE price_adjustment_id  = l_adj_id_tbl(i)
 AND ( pricing_context
     , pricing_attribute
     , pricing_attr_value_from
     , pricing_attr_value_to)
 not in (select qplat.context
     ,  qplat.attribute
     ,  qplat.setup_value_from
     ,  qplat.setup_value_to
        FROM   QP_PREQ_LINE_ATTRS_TMP QPLAT
          --   , QP_PREQ_LDETS_TMP LDETS
          --   , OE_PRICE_ADJUSTMENTS ADJ
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
          --AND QPLAT.LINE_INDEX = ADJ.HEADER_ID + nvl(ADJ.LINE_ID, 0)
          --AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_DETAIL_INDEX = l_line_detail_index_tbl(i)
          --AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          --AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          --AND LDETS.LIST_LINE_ID = l_list_line_id_tbl(i)
          --AND LDETS.PROCESS_CODE IN (QP_PREQ_PUB.G_STATUS_UNCHANGED,
          --                                  QP_PREQ_PUB.G_STATUS_UPDATED)
          --AND LDETS.LINE_INDEX = ADJ.HEADER_ID + ADJ.LINE_ID
          --AND LDETS.LINE_INDEX = oe_order_pub.g_hdr.header_id + l_line_id_tbl(i)
          --AND ADJ.PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
     ) ;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DELETED '||SQL%ROWCOUNT||' ATTRIBUTES' ) ;
  END IF;
l_stmt:=10;
FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
       INSERT INTO OE_PRICE_ADJ_ATTRIBS
        (       PRICE_ADJUSTMENT_ID
                ,PRICING_CONTEXT
                ,PRICING_ATTRIBUTE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICING_ATTR_VALUE_FROM
                ,PRICING_ATTR_VALUE_TO
                ,COMPARISON_OPERATOR
                ,FLEX_TITLE
                ,PRICE_ADJ_ATTRIB_ID
                ,LOCK_CONTROL
        )
        (SELECT /*+ index (QPLAT QP_PREQ_LINE_ATTRS_TMP_N3) */
                 l_adj_id_tbl(i)  --ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,QPLAT.SETUP_VALUE_FROM --VALUE_FROM
                ,QPLAT.SETUP_VALUE_TO   --VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
                ,OE_PRICE_ADJ_ATTRIBS_S.nextval
                ,1
          FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
            -- , QP_LDETS_v LDETS
            -- , OE_PRICE_ADJUSTMENTS ADJ
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
          --AND LDETS.LINE_INDEX = ADJ.HEADER_ID + ADJ.LINE_ID
          --AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_DETAIL_INDEX = l_line_detail_index_tbl(i)
          --AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          --AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          --AND LDETS.PROCESS_CODE in (QP_PREQ_PUB.G_STATUS_UNCHANGED,
          --                           QP_PREQ_PUB.G_STATUS_UPDATED)
          --AND ADJ.PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
 AND ( qplat.context
     , qplat.attribute
     , qplat.setup_value_from
     , qplat.setup_value_to)
 not in (select pricing_context
     ,  pricing_attribute
     ,  pricing_attr_value_from
     ,  pricing_attr_value_to
        FROM   OE_PRICE_ADJ_ATTRIBS
        WHERE PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
      ));
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' CHANGED ATTRIBS' ) ;
    END IF;
End If;
close del_attribs1;
l_stmt:=11;
l_adj_id_tbl.delete;
l_line_detail_index_tbl.delete;

open del_attribs2(l_hdr_line_index, l_hdr_line_id);
fetch del_attribs2 Bulk Collect into l_adj_id_tbl, l_line_detail_index_tbl;

If l_adj_id_tbl.count > 0 Then
 FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
 DELETE FROM OE_PRICE_ADJ_ATTRIBS  WHERE price_adjustment_id  = l_adj_id_tbl(i)
 AND ( pricing_context
     , pricing_attribute
     , pricing_attr_value_from
     , pricing_attr_value_to)
 not in (select qplat.context
     ,  qplat.attribute
     ,  qplat.setup_value_from
     ,  qplat.setup_value_to
        FROM   QP_PREQ_LINE_ATTRS_TMP QPLAT
          --   , QP_LDETS_v LDETS
          --   , OE_PRICE_ADJUSTMENTS ADJ
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
          --AND QPLAT.LINE_INDEX = ADJ.HEADER_ID + nvl(ADJ.LINE_ID, 0)
          --AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_DETAIL_INDEX = l_line_detail_index_tbl(i)
          --AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          --AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          --AND LDETS.PROCESS_CODE IN (QP_PREQ_PUB.G_STATUS_UNCHANGED,
          --                                  QP_PREQ_PUB.G_STATUS_UPDATED)
          --AND LDETS.LINE_INDEX = ADJ.HEADER_ID
          --AND ADJ.PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
     ) ;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DELETED '||SQL%ROWCOUNT||'ORDER ADJ LEVEL ATTRIBUTES' ) ;
  END IF;
l_stmt:=12;
  FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
       INSERT INTO OE_PRICE_ADJ_ATTRIBS
        (       PRICE_ADJUSTMENT_ID
                ,PRICING_CONTEXT
                ,PRICING_ATTRIBUTE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICING_ATTR_VALUE_FROM
                ,PRICING_ATTR_VALUE_TO
                ,COMPARISON_OPERATOR
                ,FLEX_TITLE
                ,PRICE_ADJ_ATTRIB_ID
                ,LOCK_CONTROL
        )
        (SELECT /*+ index (QPLAT QP_PREQ_LINE_ATTRS_TMP_N3) */
                 l_adj_id_tbl(i) --ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,QPLAT.SETUP_VALUE_FROM --VALUE_FROM
                ,QPLAT.SETUP_VALUE_TO   --VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
                ,OE_PRICE_ADJ_ATTRIBS_S.nextval
                ,1
          FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
             --, QP_LDETS_v LDETS
             --, OE_PRICE_ADJUSTMENTS ADJ
             --, QP_PREQ_LINES_TMP QPL
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
          --AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_DETAIL_INDEX = l_line_detail_index_tbl(i)
          --AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          --AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          --AND LDETS.PROCESS_CODE in (QP_PREQ_PUB.G_STATUS_UNCHANGED,
          --                           QP_PREQ_PUB.G_STATUS_UPDATED)
          --AND LDETS.LINE_INDEX = ADJ.HEADER_ID
          --AND ADJ.PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
 AND ( qplat.context
     , qplat.attribute
     , qplat.setup_value_from
     , qplat.setup_value_to)
 not in (select pricing_context
     ,  pricing_attribute
     ,  pricing_attr_value_from
     ,  pricing_attr_value_to
        FROM   OE_PRICE_ADJ_ATTRIBS
        WHERE PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i)
      ));
End If;
close del_attribs2;
l_stmt:=13;
/* Delete price_adj_attribs for order level adj*/
/*DELETE FROM Oe_Price_Adj_Attribs adjattrs
WHERE exists
(Select ADJ.PRICE_ADJUSTMENT_ID
 From   QP_LDETS_V               LDETS
       ,OE_PRICE_ADJUSTMENTS     ADJ
       ,QP_PREQ_LINES_TMP        QPLINES
 Where LDETS.LIST_LINE_ID      = ADJ.LIST_LINE_ID
 AND   LDETS.LINE_INDEX        = QPLINES.LINE_INDEX
 AND   QPLINES.LINE_TYPE_CODE  = 'ORDER'
 AND   QPLINES.LINE_ID         = ADJ.HEADER_ID
 AND   ADJ.price_adjustment_id = adjattrs.price_adjustment_id);*/

/* Delete price_adj_attribs for line level adj*/
/*DELETE FROM Oe_Price_Adj_Attribs adjattrs
WHERE exists
(Select ADJ.PRICE_ADJUSTMENT_ID
 From  QP_LDETS_V                LDETS
       ,OE_PRICE_ADJUSTMENTS     ADJ
       ,QP_PREQ_LINES_TMP        QPLINES
 Where LDETS.LIST_LINE_ID      = ADJ.LIST_LINE_ID
 AND   LDETS.LINE_INDEX        = QPLINES.LINE_INDEX
 AND   QPLINES.LINE_ID         = ADJ.LINE_ID
 AND   QPLINES.LINE_TYPE_CODE  = 'LINE'
 AND   ADJ.price_adjustment_id = adjattrs.price_adjustment_id);*/

/* insert header level adjustment attributes */
        INSERT INTO OE_PRICE_ADJ_ATTRIBS
        (       PRICE_ADJUSTMENT_ID
                ,PRICING_CONTEXT
                ,PRICING_ATTRIBUTE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICING_ATTR_VALUE_FROM
                ,PRICING_ATTR_VALUE_TO
                ,COMPARISON_OPERATOR
                ,FLEX_TITLE
                ,PRICE_ADJ_ATTRIB_ID
                ,LOCK_CONTROL
        )
        (SELECT  ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,QPLAT.SETUP_VALUE_FROM --VALUE_FROM
                ,QPLAT.SETUP_VALUE_TO   --VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
                ,OE_PRICE_ADJ_ATTRIBS_S.nextval
                ,1
          FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
             , QP_LDETS_v LDETS
             , OE_PRICE_ADJUSTMENTS ADJ
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
        --  AND LDETS.LINE_INDEX = ADJ.HEADER_ID
          AND ADJ.LINE_ID IS NULL
          AND ADJ.HEADER_ID = oe_order_pub.g_hdr.header_id
          AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          AND LDETS.PROCESS_CODE=QP_PREQ_PUB.G_STATUS_NEW
          AND LDETS.LINE_INDEX = l_hdr_line_index
          AND  l_hdr_line_id = oe_order_pub.g_hdr.header_id
          --AND QPL.PRICING_STATUS_CODE IN (QP_PREQ_PUB.G_STATUS_UPDATED,
          --                                QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
         );
l_stmt:=14;
 INSERT INTO OE_PRICE_ADJ_ATTRIBS
        (       PRICE_ADJUSTMENT_ID
                ,PRICING_CONTEXT
                ,PRICING_ATTRIBUTE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICING_ATTR_VALUE_FROM
                ,PRICING_ATTR_VALUE_TO
                ,COMPARISON_OPERATOR
                ,FLEX_TITLE
                ,PRICE_ADJ_ATTRIB_ID
                ,LOCK_CONTROL
        )
        (SELECT  ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,QPLAT.SETUP_VALUE_FROM --VALUE_FROM
                ,QPLAT.SETUP_VALUE_TO   --VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
                ,OE_PRICE_ADJ_ATTRIBS_S.nextval
                ,1
          FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
             , QP_LDETS_v LDETS
             , OE_PRICE_ADJUSTMENTS ADJ
             , QP_PREQ_LINES_TMP QPLINE
          WHERE QPLAT.pricing_status_code=QP_PREQ_PUB.G_STATUS_NEW
        --  AND QPLAT.LINE_INDEX = ADJ.HEADER_ID+nvl(ADJ.LINE_ID,0)
          AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
          AND QPLAT.LINE_INDEX = LDETS.LINE_INDEX
          AND LDETS.LIST_LINE_ID=ADJ.LIST_LINE_ID
          AND LDETS.PROCESS_CODE=QP_PREQ_PUB.G_STATUS_NEW
          AND LDETS.LINE_INDEX  = QPLINE.LINE_INDEX
        --  AND ADJ.HEADER_ID = oe_order_pub.g_hdr.header_id
          AND QPLINE.LINE_ID    = ADJ.LINE_ID
          AND QPLINE.LINE_TYPE_CODE = 'LINE'
          AND QPLINE.PRICING_STATUS_CODE IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                             QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
          AND QPLINE.PROCESS_STATUS <> 'NOT_VALID'
         );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' ATTRIBS' , 3 ) ;
  END IF;
END IF;

ELSE
--RETOBILL REQUEST EVENT
--Different handling..
  oe_debug_pub.add('Retro:Calling Oe_Retrobill_Pvt.Process_Retrobill_Adjustments,Operation:'||G_RETROBILL_OPERATION);
  Oe_Retrobill_Pvt.Process_Retrobill_Adjustments(G_RETROBILL_OPERATION);
END IF;
--RT}

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'WRONG IN REFRESH_ADJ'||SQLERRM||L_STMT , 1 ) ;
   END IF;
   raise fnd_api.g_exc_error;

End REFRESH_ADJS;
--end AG change

-- AG change --
procedure copy_Header_to_request(
 p_header_rec           OE_Order_PUB.Header_Rec_Type
,px_req_line_tbl   in out NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE
--,p_pricing_event      varchar2
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
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
           px_req_line_tbl(px_line_index).line_id := p_Header_rec.header_id;
           px_req_line_tbl(px_line_index).LINE_TYPE_CODE := 'ORDER';
        END IF;
        l_req_line_rec.REQUEST_TYPE_CODE :=p_Request_Type_Code;
        --l_req_line_rec.PRICING_EVENT :=p_pricing_event;
        --l_req_line_rec.LIST_LINE_LEVEL_CODE :=p_Request_Type_Code;
        l_req_line_rec.LINE_INDEX := px_line_index; --p_header_rec.header_id;
        l_req_line_rec.LINE_TYPE_CODE := 'ORDER';
        -- Hold the header_id in line_id for 'HEADER' Records
        l_req_line_rec.line_id := p_Header_rec.header_id;
        if  p_header_rec.pricing_date is null or
                 p_header_rec.pricing_date = fnd_api.g_miss_date then
                l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(sysdate);
        Else
                l_req_line_rec.PRICING_EFFECTIVE_DATE := p_header_rec.pricing_date;
        End If;
   IF (QP_PREQ_GRP.G_MIN_PRICING_DATE IS NULL) THEN
    QP_PREQ_GRP.G_MIN_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
    QP_PREQ_GRP.G_MAX_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
   ELSE
    IF (TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE)
        < TRUNC(QP_PREQ_GRP.G_MIN_PRICING_DATE))
THEN
     QP_PREQ_GRP.G_MIN_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
    END IF;

    IF (TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE)
              > TRUNC(QP_PREQ_GRP.G_MAX_PRICING_DATE))
THEN
     QP_PREQ_GRP.G_MAX_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
    END IF;

  END IF;
        l_req_line_rec.CURRENCY_CODE := p_Header_rec.transactional_curr_code;
        QP_PREQ_GRP.G_CURRENCY_CODE := l_req_line_rec.currency_code;
        l_req_line_rec.PRICE_FLAG := p_calculate_price_flag;
        l_req_line_rec.Active_date_first_type := 'ORD';
        l_req_line_rec.Active_date_first := p_Header_rec.Ordered_date;
        If G_ROUNDING_FLAG = 'Y' Then
          l_req_line_rec.Rounding_factor
            := Get_Rounding_factor(p_Header_rec.price_list_id);
        End If;

   G_LINE_INDEX_TBL(px_line_index)            :=  l_req_line_rec.LINE_INDEX;
   G_LINE_TYPE_CODE_TBL(px_line_index)        :=  l_req_line_rec.LINE_TYPE_CODE;
   G_PRICING_EFFECTIVE_DATE_TBL(px_line_index)
          :=  TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
   G_ACTIVE_DATE_FIRST_TBL(px_line_index)
          :=  TRUNC(l_req_line_rec.ACTIVE_DATE_FIRST);
   G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index)
          :=  l_req_line_rec.ACTIVE_DATE_FIRST_TYPE;
   G_ACTIVE_DATE_SECOND_TBL(px_line_index)
          :=  TRUNC(l_req_line_rec.ACTIVE_DATE_SECOND);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index)
          := l_req_line_rec.ACTIVE_DATE_SECOND_TYPE;
   G_LINE_QUANTITY_TBL(px_line_index)          := l_req_line_rec.LINE_QUANTITY;
   G_LINE_UOM_CODE_TBL(px_line_index)          := l_req_line_rec.LINE_UOM_CODE;
   G_REQUEST_TYPE_CODE_TBL(px_line_index)      := l_req_line_rec.REQUEST_TYPE_CODE;
   G_PRICED_QUANTITY_TBL(px_line_index)        := l_req_line_rec.PRICED_QUANTITY;
   G_UOM_QUANTITY_TBL(px_line_index)           := l_req_line_rec.UOM_QUANTITY;
   G_CONTRACT_START_DATE_TBL(px_line_index)    := l_req_line_rec.CONTRACT_START_DATE;
   G_CONTRACT_END_DATE_TBL(px_line_index)    := l_req_line_rec.CONTRACT_END_DATE;
   G_PRICED_UOM_CODE_TBL(px_line_index)        := l_req_line_rec.PRICED_UOM_CODE;
   G_CURRENCY_CODE_TBL(px_line_index)          := l_req_line_rec.CURRENCY_CODE;
   G_UNIT_PRICE_TBL(px_line_index)             := l_req_line_rec.unit_price;  -- AG
   G_PERCENT_PRICE_TBL(px_line_index)          := l_req_line_rec.PERCENT_PRICE;
   G_ADJUSTED_UNIT_PRICE_TBL(px_line_index)    := l_req_line_rec.ADJUSTED_UNIT_PRICE;
   G_PROCESSED_FLAG_TBL(px_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(px_line_index)             := l_req_line_rec.PRICE_FLAG;
   G_LINE_ID_TBL(px_line_index)                := l_req_line_rec.LINE_ID;
   G_ROUNDING_FLAG_TBL(px_line_index)
         := G_ROUNDING_FLAG;  -- AG
   G_ROUNDING_FACTOR_TBL(px_line_index)        := l_req_line_rec.ROUNDING_FACTOR;
   G_PROCESSING_ORDER_TBL(px_line_index)       := NULL;
   G_PRICING_STATUS_CODE_tbl(px_line_index)    := QP_PREQ_GRP.G_STATUS_UNCHANGED;
   G_PRICING_STATUS_TEXT_tbl(px_line_index)    := NULL;

G_QUALIFIERS_EXIST_FLAG_TBL(px_line_index)            :='N';
 G_PRICING_ATTRS_EXIST_FLAG_TBL(px_line_index)       :='N';
 G_PRICE_LIST_ID_TBL(px_line_index)                 :=NULL;
 G_PL_VALIDATED_FLAG_TBL(px_line_index)                := 'N';
 G_PRICE_REQUEST_CODE_TBL(px_line_index)        := p_header_rec.price_request_code;
 G_USAGE_PRICING_TYPE_TBL(px_line_index)        :='REGULAR';
G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_line_index) :=NULL;
G_LINE_CATEGORY_TBL(px_line_index):=NULL;
G_CATCHWEIGHT_QTY_TBL(px_line_index) := NULL;
G_ACTUAL_ORDER_QTY_TBL(px_line_index) :=NULL;
G_LINE_UNIT_PRICE_TBL(px_line_index) := NULL;
G_LIST_PRICE_OVERRIDE_FLAG_TBL(px_line_index):=NULL;
G_CHARGE_PERIODICITY_CODE_TBL(px_line_index):=NULL;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXISTING OE_ORDER_PRICE_PVT.COPY_HEADER_TO_REQUEST' , 1 ) ;
        END IF;

end copy_Header_to_request;

procedure copy_Line_to_request(
 p_Line_rec                     OE_Order_PUB.Line_Rec_Type
,px_req_line_tbl                in out nocopy   QP_PREQ_GRP.LINE_TBL_TYPE
,p_pricing_events               varchar2
,p_request_type_code            varchar2
,p_honor_price_flag             varchar2
,px_line_index in out NOCOPY NUMBER
)
is
--l_line_index  pls_integer := nvl(px_req_line_tbl.count,0);
l_req_line_rec QP_PREQ_GRP.LINE_REC_TYPE;
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
l_fulfilled_qty                NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
        G_STMT_NO := 'copy_Line_to_request#10';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
        END IF;


        --RT{
        IF p_line_rec.retrobill_request_id IS NOT NULL AND p_pricing_events <> 'RETROBILL' THEN
          --Do not price this retrobill line with other events
          oe_debug_pub.add(  'LEAVING OE_ORDER_PRICE_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
          RETURN;
        END IF;
        --RT}



     --   px_line_index := px_line_index+1;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE ID:FROM COPY LINE TO REQUEST:'||P_LINE_REC.LINE_ID ) ;
        END IF;
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
          px_req_line_tbl(px_line_index).line_id := p_Line_rec.line_id;
          px_req_line_tbl(px_line_index).LINE_TYPE_CODE := 'LINE';
        END IF;
        l_req_line_rec.Line_id := p_Line_rec.line_id;
        l_req_line_rec.REQUEST_TYPE_CODE := p_Request_Type_Code;
        --l_req_line_rec.PRICING_EVENT :=p_pricing_event;
        --l_req_line_rec.LIST_LINE_LEVEL_CODE :=p_price_level_code;
        l_req_line_rec.LINE_INDEX :=  px_line_index; --p_line_rec.header_id+p_line_rec.line_id;
        l_req_line_rec.LINE_TYPE_CODE := 'LINE';
        If p_Line_rec.pricing_date is null or
                p_Line_rec.pricing_date = fnd_api.g_miss_date then
                l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(sysdate);
        Else
                l_req_line_rec.PRICING_EFFECTIVE_DATE := p_Line_rec.pricing_date;
        End If;

	--rc
	l_req_line_rec.charge_periodicity_code := p_line_rec.charge_periodicity_code;

   IF (QP_PREQ_GRP.G_MIN_PRICING_DATE IS NULL) THEN
    QP_PREQ_GRP.G_MIN_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
    QP_PREQ_GRP.G_MAX_PRICING_DATE   := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
   ELSE
    IF (TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE)
                < TRUNC(QP_PREQ_GRP.G_MIN_PRICING_DATE))
THEN
     QP_PREQ_GRP.G_MIN_PRICING_DATE := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
    END IF;

    IF (TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE)
              > TRUNC(QP_PREQ_GRP.G_MAX_PRICING_DATE))
THEN
     QP_PREQ_GRP.G_MAX_PRICING_DATE  := TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);

    END IF;
 END IF;
        l_req_line_rec.LINE_QUANTITY := p_Line_rec.Ordered_quantity ;

        l_req_line_rec.LINE_UOM_CODE := p_Line_rec.Order_quantity_uom;

        l_req_line_rec.PRICED_QUANTITY := p_Line_rec.pricing_quantity;
        l_req_line_rec.PRICED_UOM_CODE := p_Line_rec.pricing_quantity_uom;

        l_req_line_rec.CURRENCY_CODE :=
                                        OE_Order_PUB.g_hdr.transactional_curr_code;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNIT PRICE'||P_LINE_REC.UNIT_LIST_PRICE||L_REQ_LINE_REC.CURRENCY_CODE , 3 ) ;
        END IF;
        If p_Line_rec.unit_list_price_per_pqty <> FND_API.G_MISS_NUM Then
                l_req_line_rec.UNIT_PRICE := p_Line_rec.unit_list_price_per_pqty;
        Elsif p_line_rec.unit_list_price <> FND_API.G_MISS_NUM THEN
                l_req_line_rec.UNIT_PRICE := p_line_rec.unit_list_price;
        Else
                 l_req_line_rec.UNIT_PRICE := Null;
        End If;

        l_req_line_rec.adjusted_unit_price := nvl(p_line_rec.unit_selling_price_per_pqty,
                                                  nvl(p_line_rec.unit_selling_price,p_line_rec.unit_list_price));
       --bug 2650505
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ADJ PRICE 1:'||L_REQ_LINE_REC.ADJUSTED_UNIT_PRICE ) ;
       END IF;
        if l_req_line_rec.adjusted_unit_price = FND_API.G_MISS_NUM then
          l_req_line_rec.adjusted_unit_price := NULL;
        end if;
        l_req_line_rec.PERCENT_PRICE := p_Line_rec.unit_list_percent;

        -- bug 4642002 begin call OKS API to get the UOM_QUANTITY
        -- also changed the logic to pass 0 whenever service duration or period not present
        IF (p_line_rec.item_type_code = 'SERVICE') THEN
          IF (nvl(p_line_rec.service_start_date, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE) THEN
            l_req_line_rec.contract_start_date := p_line_rec.service_start_date;
          END IF;

          IF (nvl(p_line_rec.service_end_date, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE) THEN
            l_req_line_rec.contract_end_date := p_line_rec.service_end_date;
          END IF;

          IF  (nvl(p_line_rec.service_duration,0) = 0
              OR p_line_rec.service_duration = FND_API.G_MISS_NUM
              OR  nvl(p_line_rec.service_period,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
            l_req_line_rec.UOM_QUANTITY := 0;
          Elsif (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
            l_req_line_rec.UOM_QUANTITY := p_Line_rec.service_duration;
          Elsif (p_line_rec.service_period IS NOT NULL) THEN
            /*
            INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                                         ,To_Unit   => p_Line_rec.Order_quantity_uom
                                         ,Item_ID   => p_Line_rec.Inventory_item_id
                                         ,Uom_Rate  => l_Uom_rate);
            l_req_line_rec.UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
            */
            l_req_line_rec.UOM_QUANTITY := OKS_OMINT_PUB.get_target_duration(
                                 p_start_date       => p_line_rec.service_start_date
                                ,p_end_date         => p_line_rec.service_end_date
                                ,p_source_uom       => p_line_rec.service_period
                                ,p_source_duration  => p_line_rec.service_duration
                                ,p_target_uom       => p_line_rec.Order_quantity_uom
                                ,p_org_id           => p_line_rec.org_id);
          END IF;
          IF (l_debug_level > 0) THEN
           oe_debug_pub.add('uom quantity:'||l_req_line_rec.uom_quantity, 3);
           oe_debug_pub.add('service start date:'||l_req_line_rec.contract_start_Date, 3);
           oe_debug_pub.add('service end date:'||l_req_line_rec.contract_end_date, 3);
          END IF;
          -- bug 4642002 end
        End If;

        If G_ROUNDING_FLAG = 'Y' Then
          l_req_line_rec.Rounding_factor
               := Get_Rounding_factor(p_Line_rec.price_list_id);
        End If;

     --bug3558168,if cal price = 'X' indicates a service parent line.
     IF p_line_rec.CALCULATE_PRICE_FLAG = 'X' THEN
	 l_req_line_rec.line_unit_price := p_line_rec.unit_list_price;
     END IF;

        -- modified by lkxu
     IF p_honor_price_flag = 'N' THEN
          IF p_line_rec.CALCULATE_PRICE_FLAG = 'X' THEN
                -- this is service parent line, for information only, so don't price it.
                l_req_line_rec.PRICE_FLAG := 'N';
       ELSE
                l_req_line_rec.PRICE_FLAG := 'Y';
       END IF;
     ELSE
          If p_Line_rec.calculate_Price_flag = fnd_api.g_miss_char then
                l_req_line_rec.PRICE_FLAG := 'Y';
          else
                l_req_line_rec.PRICE_FLAG := nvl(p_Line_rec.calculate_Price_flag,'Y');
          end if;
     END IF;

     -- end of modification made by lkxu

    --fnd_profile.get('ONT_DISCOUNTING_PRIVILEGE', v_discounting_privilege);

        -- If the profile is set to UNLIMITED, then even if the Order Type
        -- restrict price changes, the user can change the price

        -- If Enforce list price then execute only the PRICE Event
        If p_pricing_events <> 'PRICE' and
           l_req_line_rec.PRICE_FLAG = 'Y' and
           Enforce_list_price = 'Y'
          -- and v_discounting_privilege <> 'UNLIMITED'
           then

                l_req_line_rec.PRICE_FLAG := 'P';

        End If;

        -- Execute the pricing phase if the list price is null

        If p_pricing_events = 'PRICE' and
                 l_req_line_rec.line_quantity <> 0 and
                 l_req_line_rec.UNIT_PRICE is null then

                l_req_line_rec.PRICE_FLAG := 'Y' ;

        End If;
        -- Do not execute SHIP event for a line if the line is not ship interfaced.
        If l_req_line_rec.PRICE_FLAG = 'Y' and
                (p_Line_rec.Shipped_quantity is null or
                p_Line_rec.Shipped_quantity = fnd_api.g_miss_num or
                p_Line_rec.Shipped_quantity = 0 ) and
                p_pricing_events ='SHIP' Then
                l_req_line_rec.PRICE_FLAG := 'N';
        End If;

        l_item_type_code := oe_line_util.Get_Return_Item_Type_Code(p_Line_rec);
        -- Do not fetch the price for Configuration items and Included Items
        If l_item_type_code in( 'CONFIG','INCLUDED')
        Then

            l_req_line_rec.unit_price := 0;
            l_req_line_rec.adjusted_unit_price := 0;
            l_req_line_rec.priced_quantity := p_line_rec.ordered_quantity;
            l_req_line_rec.priced_uom_code := p_line_rec.order_quantity_uom;

            IF p_line_rec.calculate_price_flag in ( 'Y', 'P' )
            Then
                If ( G_CHARGES_FOR_INCLUDED_ITEM = 'N' and
                       l_item_type_code = 'INCLUDED')
                Then
                  l_req_line_rec.PRICE_FLAG := 'N';
                Else
                  l_req_line_rec.PRICE_FLAG := 'P';
                End If;
            Else
                 l_req_line_rec.PRICE_FLAG := 'N';

            End IF;

        End If;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ITEM TYPE CODE'||P_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
        END IF;

        l_req_line_rec.Active_date_first_type := 'ORD';
        l_req_line_rec.Active_date_first := OE_Order_Pub.G_HDR.Ordered_date;

        If p_Line_rec.schedule_ship_date is not null then
          l_req_line_rec.Active_date_Second_type := 'SHIP';
          l_req_line_rec.Active_date_Second := p_Line_rec.schedule_ship_date;
        End If;

        -- Copied Logic from populate_temp_Tables
        If l_req_line_rec.currency_code is NULL
      or l_req_line_rec.currency_code = FND_API.G_MISS_CHAR
 THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CURRENCY CODE IS NULL' , 4 ) ;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
          -- Question: Pricing Engine should populate g_currency_code?
        End If;

        IF ( l_req_line_rec.PRICING_EFFECTIVE_DATE IS NULL ) THEN
          RAISE  FND_API.G_EXC_ERROR;
        END IF;
         -- ?? Pricing Engine should populate G_MIN_PRICING_DATE, G_MAX_PRICING_DATE

     /*   IF ( l_req_line_rec.price_flag = 'Y') THEN
          l_req_line_rec.unit_price := NULL;
        END IF;  */

-- start OPM  2434270
   G_catchweight_qty_tbl(px_line_index) := NULL;
   g_actual_order_qty_tbl(px_line_index):= NULL;

  -- for bug 4938837, do not need OPM logic and original list price check for service parent line
  IF (nvl(p_line_rec.calculate_price_flag, 'Y') <> 'X') THEN -- bug 4938837
   -- bug 3658057
   l_fulfilled_qty := NVL(p_line_rec.fulfilled_quantity, NVL(p_line_rec.shipped_quantity, NVL(p_line_rec.ordered_quantity, 0)));

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('l_fulfilled_qty:'|| l_fulfilled_qty);
   END IF;

        IF oe_line_util.dual_uom_control   -- INVCONV Process_Characteristics
                        (p_line_rec.inventory_item_id
                        ,p_line_rec.ship_from_org_id
                        ,l_item_rec) THEN


-- IF l_item_rec.ont_pricing_qty_source = 1   THEN -- INVCONV price by quantity 2
           IF l_item_rec.ont_pricing_qty_source = 'S' THEN  -- INVCONV
               IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'DUAL - ONT_PRICING_QTY_SOURCE = S IN OEXVOPRB.PLS ' ) ;
                END IF;
                        l_req_line_rec.LINE_QUANTITY := p_Line_rec.Ordered_quantity2 ;
                        l_req_line_rec.LINE_UOM_CODE := p_Line_rec.Ordered_quantity_uom2 ;
                        G_catchweight_qty_tbl(px_line_index) := p_line_rec.shipped_quantity2;
                        g_actual_order_qty_tbl(px_line_index) := l_fulfilled_qty; -- bug 3658057

                        IF (l_req_line_rec.price_flag = 'N') THEN
                           l_req_line_rec.price_flag := 'C';
                        END IF;


                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('OM Order Qty:'||p_line_rec.ordered_quantity);
                    oe_debug_pub.add('actual order qty :'|| g_actual_order_qty_tbl(px_line_index) ) ;
                 END IF;

                else
                        l_req_line_rec.LINE_QUANTITY := p_Line_rec.Ordered_quantity ;
                        l_req_line_rec.LINE_UOM_CODE := p_Line_rec.Order_quantity_uom ;
           END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DUAL - PRICING QUANTITY IS : ' ||L_REQ_LINE_REC.LINE_QUANTITY ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DUAL -  PRICING QUANTITY UOM IS : ' || L_REQ_LINE_REC.LINE_UOM_CODE )
;
        END IF;
-- Pack J catchweight
        ELSIF  OE_CODE_CONTROL.Code_Release_level >= '110510' THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('inventory_item_id:'|| p_line_rec.inventory_item_id);
                  oe_debug_pub.add('ship_from_org_id  :'|| p_line_rec.ship_from_org_id  );
              END IF;

              IF (p_line_rec.inventory_item_id IS NOT NULL AND
                 p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
                 (p_line_rec.ship_from_org_id  IS NOT NULL AND
                 p_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
                    x_item_rec := OE_Order_Cache.Load_Item (p_line_rec.inventory_item_id
                                                        ,p_line_rec.ship_from_org_id);
              END IF;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('ont_pricing_qty_source:'|| l_item_rec.ont_pricing_qty_source);
                  oe_debug_pub.add('tracking_quantity_ind:'|| l_item_rec.tracking_quantity_ind);
                  oe_debug_pub.add('wms_enabled_flag:'|| l_item_rec.wms_enabled_flag);
              END IF;
              --IF  x_item_rec.ont_pricing_qty_source = 1   AND -- INVCONV
              IF x_item_rec.ont_pricing_qty_source = 'S' AND -- INVCONV
                  x_item_rec.tracking_quantity_ind = 'P' and
                  x_item_rec.wms_enabled_flag = 'Y' THEN
                  IF (l_req_line_rec.price_flag = 'N') THEN
                      l_req_line_rec.price_flag := 'C';
                  END IF;
                  IF p_Line_rec.Ordered_quantity2 IS NOT NULL THEN
 /*<< This should be possible for referenced returns if ordered qty2 is populated based on shipped_quantity2>> */
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Ordered_quantity2 is NOT null ');
                     END IF;
                     l_req_line_rec.LINE_QUANTITY := p_Line_rec.Ordered_quantity2 ;
                     l_req_line_rec.LINE_UOM_CODE := p_Line_rec.Ordered_quantity_uom2 ;
                     g_actual_order_qty_tbl(px_line_index) := l_fulfilled_qty;  -- bug 3658057
                  ELSE
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Ordered_quantity2 is null');
                     END IF;

                     l_dummy := WMS_CATCH_WEIGHT_GRP.Get_Default_Secondary_Quantity (
                         p_api_version                 => 1.0
                        ,x_return_status               => x_return_status
                        ,x_msg_count                   => x_msg_count
                        ,x_msg_data                     => x_msg_data
                        ,  p_organization_id        => p_line_rec.ship_from_org_id
                        , p_inventory_item_id    => p_line_rec.inventory_item_id                        , p_quantity                      => p_line_rec.ordered_quantity
                        , p_uom_code                    => p_line_rec.order_quantity_uom
                        , x_secondary_quantity    => x_secondary_quantity --returns default catch wt qty
                        , x_secondary_uom_code  =>   x_secondary_uom_code  --returns default catch wt uom
                     );

                     IF l_debug_level  > 0 THEN
                             oe_debug_pub.add('x_secondary_qauntity:'|| x_secondary_quantity);
                             oe_debug_pub.add('x_secondary_uom_code:'|| x_secondary_uom_code);
                     END IF;
   /* Populating x_secondary_uom_code with the value in x_item_rec, because wms api is returning null */
                     x_secondary_uom_code := x_item_rec.secondary_uom_code;
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('after populating from x_item_rec :');
                        oe_debug_pub.add('x_secondary_uom_code : '||x_secondary_uom_code);
                     END IF;
                     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('Error getting secondary UOM/quantity from WMS API. Return Status: '||x_return_status||' msg_count:'||x_msg_count);
                        END IF;
                        oe_msg_pub.transfer_msg_stack;
                         RAISE FND_API.G_EXC_ERROR;
                      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('Error getting secondary UOM/quantity from WMS API. Return Status: '||x_return_status||' msg_count:'||x_msg_count);
                        END IF;
                        oe_msg_pub.transfer_msg_stack;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;

                     l_req_line_rec.LINE_QUANTITY :=  x_secondary_quantity;

                     l_req_line_rec.LINE_UOM_CODE :=  x_secondary_uom_code;
                     g_actual_order_qty_tbl(px_line_index) := l_fulfilled_qty; -- bug3658057
                  END IF; -- end check for ordered_quantity2

                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('fulfilled_quantity:'|| p_line_rec.fulfilled_quantity);
                     oe_debug_pub.add('shipped_quantity:'|| p_line_rec.shipped_quantity);
                     oe_debug_pub.add('shipped_quantity2  :'|| p_line_rec.shipped_quantity2);
                     oe_debug_pub.add('source_type_code  :'|| p_line_rec.source_type_code);
                     oe_debug_pub.add('line_category_code  :'|| p_line_rec.line_category_code);
                     oe_debug_pub.add('reference_line_id  :'|| p_line_rec.reference_line_id);
                  END IF;

                  IF p_line_rec.shipped_quantity IS NOT NULL AND
                     p_line_rec.shipped_quantity <> FND_API.G_MISS_NUM THEN
                     IF p_line_rec.shipped_quantity2 IS NOT NULL AND
                        p_line_rec.shipped_quantity2 <> FND_API.G_MISS_NUM AND
                        p_line_rec.shipped_quantity2 <> 0 THEN
                        G_catchweight_qty_tbl(px_line_index) := p_line_rec.shipped_quantity2;
                     ELSE -- shipped_quantity2 is null
                       IF  p_line_rec.source_type_code = 'EXTERNAL' OR
                           p_line_rec.line_category_code = 'RETURN' THEN -- convert shipped_quantity to shipped_quantity2 for dropship and un-referenced returns

                           IF p_line_rec.reference_line_id is NOT NULL THEN --referenced return
                              -- G_catchweight_qty_tbl(px_line_index) := NULL;
/*<<since there is tolerance in returns also, for reference returns, we need to
prorate. For example, return 12 qty of 24lb, return tolerance is 20%.  If received qty is 11, we should prorate the catchweight qty to be 22lb.>> */
                              G_catchweight_qty_tbl(px_line_index):= p_line_rec.ordered_quantity2 * (p_line_rec.shipped_quantity/p_line_rec.ordered_quantity);
                           ELSE --unrefernced return and dropship lines
                              l_shipped_quantity2 :=
                                INV_CONVERT.INV_UM_CONVERT(
                                  item_id       => p_line_rec.inventory_item_id,
                                  precision     =>NULL,
                                  from_quantity => p_line_rec.shipped_quantity,
                                  from_unit     => p_line_rec.order_quantity_uom,
                                  to_unit       => x_item_rec.secondary_uom_code,
                                  from_name     =>NULL,
                                  to_name       =>NULL);
                                G_catchweight_qty_tbl(px_line_index) :=l_shipped_quantity2;
                           END IF; --check for reference_line_id
                       ELSE /*<< raise error here if shipped_quantity exists but not shipped_quantity2>> -- This error should not be raised for returns and dropship orders. */
                           IF l_debug_level  > 0 THEN
                              oe_debug_pub.add('Shipped_quantity2 is null and not dropship, return- Raise error');
                           END IF;
                           FND_MESSAGE.SET_NAME('ONT','ONT_CATCHWEIGHT_QTY2_REQUIRED');
                           OE_MSG_PUB.Add;
                           RAISE FND_API.G_EXC_ERROR;
                       END IF; -- end checks for source_type_code
                     END IF; -- end checks for shipped_quantity2
                  END IF; -- end check for shipped_quantity
              END IF; -- end checks for discrete catchweight
        END IF; -- end of check for opm/discrete

-- Pack J catchweight
-- end OPM 2434270

-- Override List Price
        IF OE_CODE_CONTROL.Code_Release_level >= '110510' THEN
           IF p_line_rec.original_list_price IS NOT NULL AND
              p_line_rec.unit_list_price IS NOT NULL THEN --AND --bug4080363
          --  p_line_rec.unit_list_price <> p_line_rec.original_list_price AND
          -- bug 3491752
              /*nvl(fnd_profile.value('ONT_LIST_PRICE_OVERRIDE_PRIV'), 'NONE')*/          --    G_LIST_PRICE_OVERRIDE = 'UNLIMITED' THEN --bug4080363
              l_req_line_rec.list_price_override_flag := 'Y';
              l_req_line_rec.line_unit_price := p_line_rec.unit_list_price;
              IF (l_req_line_rec.price_flag = 'N') THEN
                  l_req_line_rec.price_flag := 'C';
              END IF;
           ELSE
              -- adding this because qp did not handle null value in some file versions
              l_req_line_rec.list_price_override_flag := 'N';
           END IF;
        END IF;
-- Override List Price
  END IF; -- bug 4938837

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('list_price_override_flag:'||l_req_line_rec.list_price_override_flag);
           oe_debug_pub.add('unit_price:'||l_req_line_rec.unit_price);
           oe_debug_pub.add('line_unit_price:'||l_req_line_rec.line_unit_price);
           oe_debug_pub.add('unit_list_price_per_pqty:'||p_line_rec.unit_list_price_per_pqty);
           oe_debug_pub.add('original_list_price:'||p_line_rec.original_list_price||':unit_list_price:'||p_line_rec.unit_list_price);
        END IF;
        -- bug 2812566, set price_flag to be 'N' when line is cancelled
        IF p_line_rec.ordered_quantity = 0 THEN
                l_req_line_rec.PRICE_FLAG := 'N';
        END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'POPULATING BULK INSERT TABLES' , 4 ) ;
       oe_debug_pub.add('inserting line index:'||l_req_line_rec.line_index);
   END IF;

   G_LINE_INDEX_TBL(px_line_index)            :=  l_req_line_rec.LINE_INDEX;
   G_LINE_TYPE_CODE_TBL(px_line_index)        :=  l_req_line_rec.LINE_TYPE_CODE;
   G_PRICING_EFFECTIVE_DATE_TBL(px_line_index):=  TRUNC(l_req_line_rec.PRICING_EFFECTIVE_DATE);
   G_ACTIVE_DATE_FIRST_TBL(px_line_index)     :=  TRUNC(l_req_line_rec.ACTIVE_DATE_FIRST);
  G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index):=  l_req_line_rec.ACTIVE_DATE_FIRST_TYPE;
   G_ACTIVE_DATE_SECOND_TBL(px_line_index)    :=  TRUNC(l_req_line_rec.ACTIVE_DATE_SECOND);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index):= l_req_line_rec.ACTIVE_DATE_SECOND_TYPE;
  --l_req_line_rec.priced_quantity := NULL;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'QUANTITY'||L_REQ_LINE_REC.LINE_QUANTITY||' '||L_REQ_LINE_REC.PRICED_QUANTITY , 3 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE FLAG'||L_REQ_LINE_REC.PRICE_FLAG ) ;
   END IF;
   G_LINE_QUANTITY_TBL(px_line_index)          := l_req_line_rec.LINE_QUANTITY;
   G_LINE_UOM_CODE_TBL(px_line_index)          := l_req_line_rec.LINE_UOM_CODE;
   G_REQUEST_TYPE_CODE_TBL(px_line_index)      := l_req_line_rec.REQUEST_TYPE_CODE;
   G_PRICED_QUANTITY_TBL(px_line_index)        := l_req_line_rec.PRICED_QUANTITY;
   G_UOM_QUANTITY_TBL(px_line_index)           := l_req_line_rec.UOM_QUANTITY;
   G_CONTRACT_START_DATE_TBL(px_line_index)         := l_req_line_rec.CONTRACT_START_DATE;
   G_CONTRACT_END_DATE_TBL(px_line_index)           := l_req_line_rec.CONTRACT_END_DATE;
   G_PRICED_UOM_CODE_TBL(px_line_index)        := l_req_line_rec.PRICED_UOM_CODE;
   G_CURRENCY_CODE_TBL(px_line_index)          := l_req_line_rec.CURRENCY_CODE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNIT PRICE'||L_REQ_LINE_REC.UNIT_PRICE||' '||L_REQ_LINE_REC.ADJUSTED_UNIT_PRICE ) ;
    END IF;
   G_UNIT_PRICE_TBL(px_line_index)             := l_req_line_rec.unit_price;  -- AG
   G_PERCENT_PRICE_TBL(px_line_index)          := l_req_line_rec.PERCENT_PRICE;
   G_ADJUSTED_UNIT_PRICE_TBL(px_line_index)    := l_req_line_rec.ADJUSTED_UNIT_PRICE;
   G_PROCESSED_FLAG_TBL(px_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(px_line_index)             := l_req_line_rec.PRICE_FLAG;
   G_LINE_ID_TBL(px_line_index)                := l_req_line_rec.LINE_ID;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE ID IN G_LINE_ID_TBL:'|| G_LINE_ID_TBL ( PX_LINE_INDEX ) ) ;
   END IF;
   G_ROUNDING_FLAG_TBL(px_line_index)          := G_ROUNDING_FLAG;  -- AG
   G_ROUNDING_FACTOR_TBL(px_line_index)        := l_req_line_rec.ROUNDING_FACTOR;
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
G_LIST_PRICE_OVERRIDE_FLAG_TBL(px_line_index) := l_req_line_rec.list_price_override_flag;
G_LINE_UNIT_PRICE_TBL(px_line_index) := l_req_line_rec.line_unit_price;
--rc
G_CHARGE_PERIODICITY_CODE_TBL(px_line_index) := l_req_line_rec.CHARGE_PERIODICITY_CODE;
-- Bug3380345
   IF G_LIST_PRICE_OVERRIDE_FLAG_TBL(px_line_index) = 'Y' AND
      p_pricing_events = 'PRICE' THEN
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'setting process code as UPDATED for override list price');
      END IF;
      G_PRICING_STATUS_CODE_tbl(px_line_index)    := QP_PREQ_GRP.G_STATUS_UPDATED;
   END IF;


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXISTING OE_ORDER_PRICE_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
        END IF;

end copy_Line_to_request;

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
		oe_debug_pub.add('G_CHARGE_PERIODICITY_CODE_TBL.Count:'||G_CHARGE_PERIODICITY_CODE_TBL.COUNT);
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
                 p_contract_start_date =>    G_CONTRACT_START_DATE_tbl,
                 p_contract_end_date   =>    G_CONTRACT_END_DATE_tbl,
                 p_catchweight_qty     =>    G_CATCHWEIGHT_QTY_tbl,
                 p_actual_order_qty    =>    G_ACTUAL_ORDER_QTY_TBL,
                 p_LINE_UNIT_PRICE    =>     G_LINE_UNIT_PRICE_TBL,
                 p_LIST_PRICE_OVERRIDE_FLAG    =>    G_LIST_PRICE_OVERRIDE_FLAG_TBL,
		 p_CHARGE_PERIODICITY_CODE => G_CHARGE_PERIODICITY_CODE_TBL,  --rc
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

-- This function is to find out whether it's better to query all lines in the order
-- or query changed lines one by one
FUNCTION Need_Query_All_Lines(
p_header_id NUMBER
) RETURN VARCHAR2
IS
l_total_lines NUMBER;
l_num_changed_lines NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
i pls_integer;
BEGIN

  -- only one changed line, query that line
  IF (OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count < 2) THEN
    RETURN 'N';
  END IF;

  -- find out the total number of lines in the order
  BEGIN
    Select count(header_id) into l_total_lines from oe_order_lines
    where header_id = p_header_id;
  EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('could not find out nocopy total number of lines!');
    END IF;
    RETURN 'N';
  END;

  IF (l_total_lines > OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count) THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('total lines larger than changed '||l_total_lines
                 ||' '||OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count);
    END IF;
    RETURN 'N';
  ELSE
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('total lines smaller than or equal to changed '||l_total_lines
                 ||' '||OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count);
    END IF;

    l_num_changed_lines := 0;
    i := Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.FIRST;
    While i is Not Null Loop
      if oe_line_adj_util.G_CHANGED_LINE_TBL(i).header_id = p_header_id then
        l_num_changed_lines := l_num_changed_lines + 1;
      end if;
      i:= Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.Next(i);
    End Loop;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('total changed lines in this order '||l_num_changed_lines);
    END IF;
    IF (l_total_lines = l_num_changed_lines) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END IF;

  RETURN 'N';

EXCEPTION
WHEN OTHERS THEN
 RETURN 'N';
END Need_Query_All_Lines;


-- bug4529937
PROCEDURE Query_Changed_Lines(p_header_id IN  NUMBER,
			      x_line_tbl  OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE ) AS
  i PLS_INTEGER;
  l_line_rec  OE_ORDER_PUB.LINE_REC_TYPE;
  j PLS_INTEGER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   i := Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.FIRST;
   j := 1;
   While i is Not Null Loop
      Begin
	 --bug 3020702
         IF l_debug_level > 0 THEN
	    oe_debug_pub.add('header_id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).header_id);
	 END IF;
	 if oe_line_adj_util.G_CHANGED_LINE_TBL(i).header_id = p_header_id then

	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('query line_id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id);
	    END IF;
	    query_line(Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id,l_line_rec);
	    x_line_tbl(j):=l_line_rec;
	    j:=j+1;

            oe_debug_pub.add('link to line id:'|| l_line_rec.link_to_line_id);

	    LOOP
	    IF l_line_rec.link_to_line_id IS NOT null
	       and l_line_rec.link_to_line_id <> FND_API.G_MISS_NUM
	       and l_line_rec.link_to_line_id <> l_line_rec.line_id
	       and NOT OE_LINE_ADJ_UTIL.G_CHANGED_LINE_TBL.exists(mod(l_line_rec.link_to_line_id,G_BINARY_LIMIT))
	       and NOT G_ADDED_PARENT_TBL.exists(mod(l_line_rec.link_to_line_id,G_BINARY_LIMIT)) THEN
                 --child line has changed, need to send in parent lines to be repriced.
                 --model line should not be added aga if exists in G_CHANGED_LINE_TBL.
                 --use linked to line id to find the immediate parent.
              	 G_ADDED_PARENT_TBL(mod(l_line_rec.link_to_line_id,G_BINARY_LIMIT)) := l_line_rec.link_to_line_id;
                 query_line(l_line_rec.link_to_line_id,l_line_rec);
	         x_line_tbl(j):=l_line_rec;
	         j:=j+1;
	    ELSE
	      EXIT;
	    END IF;
            END LOOP;



	 end if;
      Exception
	 When no_data_found Then
	    IF l_debug_level > 0 THEN
	       Oe_Debug_Pub.add('No data found for line id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id);
	    END IF;
      End;
      i:= Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.Next(i);
   End Loop;
END Query_Changed_Lines;

procedure calculate_adjustments(
x_return_status out nocopy varchar2

,p_line_id                                      number
,p_header_id                            number
,p_pricing_events varchar2
,p_Control_Rec                          OE_ORDER_PRICE_PVT.CONTROL_REC_TYPE
,p_action_code                in  Varchar2
,x_any_frozen_line out nocopy Boolean

,x_Header_Rec out nocopy oe_Order_Pub.Header_REc_Type

,px_line_Tbl                       in out nocopy  oe_Order_Pub.Line_Tbl_Type
)
is
l_return_status  varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_return_status_Text     varchar2(240) ;
l_header_rec            OE_Order_PUB.Header_Rec_Type;
l_Line_Tbl              OE_Order_PUB.Line_Tbl_Type;

--1472635
l_temp_line_tbl         OE_Order_PUB.Line_Tbl_type;
i2                      PLS_INTEGER;
l_all_lines_from_db         Boolean :=False;

l_Line_Rec              OE_Order_PUB.Line_Rec_Type;

-- AG change
l_line_index NUMBER := 0;
line_tbl_index                             pls_integer;
i                                  pls_integer;
j                                  pls_integer;
l_bypass_pricing    varchar2(30) :=  nvl(FND_PROFILE.VALUE('QP_BYPASS_PRICING'),'N');
l_dummy                                 Varchar2(1);
l_header_id                             NUMBER;
l_any_frozen_line BOOLEAN:=FALSE;
l_calculate_price_flag varchar2(1);
l_message_displayed Boolean:=FALSE;
--btea begin
l_Control_Rec                           QP_PREQ_GRP.CONTROL_RECORD_TYPE;
--btea end
l_order_line_id NUMBER;
l_service_reference_line_id NUMBER;
l_completely_frozen BOOLEAN := TRUE;
l_line_attr_index number:=0;
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_total_lines NUMBER;
G_INT_CHANGED_LINE_ON Varchar2(3):= nvl(FND_PROFILE.VALUE('ONT_INTERNAL_CHANGED_LINE'),'Y');
l_header_id2 NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_check_line_flag varchar2(1);
l_pass_line varchar2(1);
--2740845 begin
l_agreement_name  varchar2(240);
l_revision        varchar2(50);
--2740845 end
l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
--bug 3968023
l_event_in_phase1  VARCHAR2(1);
l_sql      varchar2(4000); --bug 9436193

begin

    oe_debug_pub.add('Entering oe_order_price_pvt.calulate_adjustments', 1);

    reset_all_tbls;
    --DELETE FROM QP_PREQ_LINES_TMP;
    --DELETE FROM QP_PREQ_LINE_ATTRS_TMP;
    --DELETE FROM QP_PREQ_LDETS_TMP;
    --DELETE FROM QP_PREQ_QUAL_TMP;
    --DELETE FROM QP_PREQ_RLTD_LINES_TMP;

    G_STMT_NO := 'calculate_adjustments#10';


    if (p_line_id is null or p_line_id = FND_API.G_MISS_NUM)
       and ( p_header_id is null or p_header_id = FND_API.G_MISS_NUM)
       and  px_line_Tbl.count =0
       and  p_control_rec.p_use_current_header = FALSE
    then
           l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id or Header Id ');
            OE_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    G_STMT_NO := 'calculate_adjustments#20';
    if p_Line_id is not null and p_Header_id is not null then
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,
            'oe_line_adj.calulate_adjustments'
            ,'Keys are mutually exclusive');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    --	Query the header Record
    if p_header_id is not null  and p_Header_id <> FND_API.G_MISS_NUM then

        G_STMT_NO := 'calculate_adjustments#30';

        Begin
        --	OE_Order_PUB.g_hdr := OE_ORDER_CACHE.g_header_rec;
          query_header( p_header_id => p_header_id, x_header_rec=>oe_order_pub.g_hdr);
        Exception when no_data_found then
            x_return_status := 'NOOP';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  G_STMT_NO||'INVALID HEADER_ID '||P_HEADER_ID , 1 ) ;
            END IF;
            Return;
        End;

        G_STMT_NO := 'calculate_adjustments#40';
        j:=1;

        Begin

            oe_debug_pub.add('Before querying lines for header:'||p_Header_id||' event:'||p_pricing_events);
            -- How to determine whether all lines needs to be passed to Pricing Engine?
            -- 1. When BOOK button is pressed, all lines needs to be passed
            --     because caller wants line information back
            -- 2. When this procedure is called for G_PRICE_ADJ delayed request, pass all
            -- 3. If QP API says all line needs to be passed, do so
            -- 4. If QP API says all line no but changed line yes, see whether changed line
            --    table has all lines, if yes, pass all lines; if no, pass changed lines
            -- 5. If QP API says all line no and changed line no, do not pass any line

            G_PASS_ALL_LINES := 'N';
            If G_INT_CHANGED_LINE_ON = 'Y'
               AND p_pricing_Events IS NOT NULL
               AND NOT (OE_GLOBALS.G_RECURSION_MODE <> 'Y' and p_pricing_events = 'BOOK')
               AND (p_pricing_events = 'SHIP' OR (NOT Oe_Line_Adj_Util.has_service_lines(p_header_id)))
               AND (p_action_code IS NULL or p_action_code <> 'PRICE_ORDER')
               --RT{
               AND p_pricing_events <> 'RETROBILL'
               --RT}
            Then

                -- call QP API to determine whether or not to
                -- call lines to pricing engine.
                QP_UTIL_PUB.Get_Order_Lines_Status(p_pricing_events,l_order_status_rec);


                oe_debug_pub.add('  All_lines_flag returned from pricing:'||l_order_status_rec.all_lines_flag);
                oe_debug_pub.add('  Changed_lines_flag returned from pricing:'||l_order_status_rec.Changed_lines_flag);


                If l_order_status_rec.ALL_LINES_FLAG = 'Y'
                    and nvl(OE_LINE_ADJ_UTIL.G_SEND_ALL_LINES_FOR_DSP,'Y') = 'Y'
                    and p_pricing_events <> 'SHIP'
                Then  --bug 2965218
               ----------------------------------------------------------------
               --Pricing says pass all lines, use query_lines is more efficient
               --action_code = 'PRICE_ORDER' user asks for repricing all lines
               ----------------------------------------------------------------
               /* query_lines(p_header_id => p_Header_id
                           , p_line_id                   => Null
                           , x_line_tbl => l_Line_Tbl);
                */
                    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
                        G_PASS_ALL_LINES := 'R';
                    ELSE
                        G_PASS_ALL_LINES := 'Y';
                    END IF;
               Elsif l_order_status_rec.CHANGED_LINES_FLAG = 'Y'
                    OR nvl(OE_LINE_ADJ_UTIL.G_SEND_ALL_LINES_FOR_DSP,'Y') = 'N'
                    OR p_pricing_events = 'SHIP'
               Then
                    IF Need_Query_All_Lines(p_header_id) = 'Y' THEN
                        IF l_debug_level > 0 THEN
                        oe_debug_pub.add(' Need query all lines because all lines are changed');
                        END IF;
                        G_PASS_ALL_LINES := 'Y';
                    ELSE
                        -------------------------------------------------------------------
                        --Pricing says passing only changed lines, use query_line
                        --------------------------------------------------------------------
                        oe_debug_pub.add('Query individual line changed:'||OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count);

                        --bug4529937  have put the code to query for changed lines in a procedure
                        Query_Changed_Lines(p_header_id => p_header_id,
                          x_line_tbl  => l_line_tbl);
                        G_PASS_ALL_LINES := 'N';
                    END IF;  -- Need_Query_All_Lines
                END IF; -- QP API;
            Else
                G_PASS_ALL_LINES := 'Y';
            End If; -- changed_line no, no book button, no price_adj delayed request

            If G_PASS_ALL_LINES in  ('Y', 'R') Then
                --bug4529937 if the call is from mass change api, and there are more lines remaining to be processed after the current set, we would just pass the changed lines to pricing engine
                IF oe_mass_change_pvt.Lines_Remaining = 'Y' THEN
                    IF l_debug_level > 0 THEN
                        oe_debug_pub.add(' Query only changed line');
                    END IF;
                    Query_Changed_Lines(p_header_id => p_header_id, x_line_tbl  => l_line_tbl);
                    l_all_lines_from_db := FALSE;
                ELSE
                    IF l_debug_level > 0 THEN
                        oe_debug_pub.add(' Pass all the lines');
                    END IF;
                    query_lines(p_header_id => p_Header_id, p_line_id => Null, x_line_tbl => l_Line_Tbl);
                    --1472635
                    l_all_lines_from_db := True;
                END IF;
            End If;
            oe_debug_pub.add('line_count after querying:'||l_Line_Tbl.count);

           /* debug statement
                   For i in l_Line_Tbl.first .. l_Line_Tbl.last Loop
                    oe_debug_pub.add('line id in l_line_tbl!:'||l_Line_Tbl(i).line_id);
           End Loop; */

        Exception when no_data_found then
           -- No need to process this order
            x_return_status := 'NOOP';
            oe_debug_pub.add(G_STMT_NO||'Invalid header_id '||p_Header_id,1);
            Return;
        End;

    ELSE -- Query the line Record
        G_STMT_NO := 'calculate_adjustments#50';
        If px_line_Tbl.count = 0	Then
            Begin
                query_lines(p_line_id =>p_line_id, p_header_id => Null, x_line_tbl=>l_Line_Tbl );
            Exception when no_data_found then
               -- No need to process this line
                x_return_status := 'NOOP';
                oe_debug_pub.add(G_STMT_NO||'Invalid line_id '||p_line_id,1);
                Return;
            End ;
        Else
            l_Line_Tbl := px_line_Tbl;
        End If;

        G_STMT_NO := 'calculate_adjustments#60';

        If p_control_rec.p_use_current_header = FALSE Then
            Begin
                query_header(l_line_tbl(1).header_id, oe_order_pub.g_hdr);
            Exception when no_data_found then
               -- No need to process this order
                x_return_status := 'NOOP';
                oe_debug_pub.add(G_STMT_NO||'Invalid header_id '||l_line_Tbl(1).Header_id,1);
                Return;
            End ;
        Else
             --Do Nothing since the flag says that the global record has been set
            NULL;
        End If;
    END IF;

    x_header_rec := oe_order_pub.g_hdr;
    G_STMT_NO := 'calculate_adjustments#110';

    line_Tbl_Index := l_Line_Tbl.First;
    While line_Tbl_Index is not null loop
        -- Do not price the config items
        --If oe_line_util.Get_Return_Item_Type_Code(l_Line_Tbl(line_Tbl_Index)) <> 'CONFIG' Then

        -- Added to check if Agreement is Active for Bug#2740845
        If l_line_tbl(line_Tbl_Index).agreement_id is not null Then
            BEGIN
                Select 'x' into l_dummy from dual
                where exists (select 'x' from oe_agreements_vl where
                agreement_id = l_line_tbl(line_Tbl_Index).agreement_id and
               ( trunc(nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE,sysdate))
                between
                trunc(nvl(start_date_active, nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE,sysdate)))
                and
                trunc(nvl(end_date_active, nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE, sysdate)))));

               --If l_dummy <>'x' then

              Exception
               When no_data_found then
               Begin
               select name, revision into l_agreement_name, l_revision
               from oe_agreements_vl where agreement_id =
               l_line_tbl(line_Tbl_Index).agreement_id;

               Exception
               When no_data_found then
               null;
               End;
              fnd_message.set_name('ONT','ONT_INVALID_AGR_REVISION');
              fnd_message.set_TOKEN('AGREEMENT',l_agreement_name||' : '||l_revision);
              fnd_message.set_TOKEN('PRICING_DATE',l_line_tbl(line_Tbl_Index).PRICING_DATE);
              OE_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END;
        End If;
        --End 2740845

        -- Populate that Global Structure
        OE_Order_PUB.G_LINE := l_Line_Tbl(line_Tbl_Index);
        If OE_Order_PUB.G_LINE.unit_list_price = fnd_api.g_miss_num then
            OE_Order_PUB.G_LINE.unit_list_price:= Null;
        End If;

        --RT{
        IF G_PRICING_EVENT='RETROBILL'
           AND nvl(G_RETROBILL_OPERATION,'xx')<>'CREATE'
           AND l_Line_Tbl(line_Tbl_Index).retrobill_request_id IS NOT NULL THEN
          --a reprice of retrobill order, need to preprocess adjustments
          Oe_Retrobill_Pvt.Preprocess_Adjustments(l_Line_Tbl(line_Tbl_Index).orig_sys_document_ref,
                                                  l_Line_Tbl(line_Tbl_Index).orig_sys_line_ref,
                          l_Line_Tbl(line_Tbl_Index).header_id, --bug3738043
                                                  l_Line_Tbl(line_Tbl_Index).line_id   );
        END IF;
        --RT}


        If  (OE_Order_PUB.G_LINE.Service_Reference_Line_Id <> FND_API.G_MISS_NUM and
              OE_Order_PUB.G_LINE.Service_Reference_Line_Id is not null)
        Then
         /* Added the following if condition for fixing the bug 1828553 */
         /* If the service reference context is ORDER, then the service_reference*/
         /*line_id is the line_id of the parent. However, if the service ref */
         /*context is Customer Product then we need to first retrieve the */
         /*original order line id */

            IF l_Line_Tbl(line_Tbl_Index).item_type_code = 'SERVICE' AND
            l_Line_Tbl(line_Tbl_Index).service_reference_type_code='CUSTOMER_PRODUCT' AND
            l_line_Tbl(line_Tbl_Index).cancelled_flag = 'N' AND
            l_Line_Tbl(line_Tbl_Index).service_reference_line_id IS NOT NULL
            THEN
                oe_debug_pub.add('1828553: Line is a customer product');
                OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
                   ( x_return_status    => l_return_status
                   , p_reference_line_id => l_Line_Tbl(line_Tbl_Index).service_reference_line_id
                   , p_customer_id       => l_Line_Tbl(line_Tbl_Index).sold_to_org_id
                   , x_cust_product_line_id => l_order_line_id
                   );
                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    oe_debug_pub.add('1828553: Success');
                    oe_debug_pub.add('1828553: Service line id is ' || l_order_line_id);
                    l_service_reference_line_id := l_order_line_id;
                ELSE
                    oe_debug_pub.add('Not able to retrieve cust product line id');
                    RAISE NO_DATA_FOUND;
                END IF;
            ELSE
                l_service_reference_line_id := l_Line_Tbl(line_Tbl_Index).service_reference_line_id;
            END IF;

            oe_debug_pub.add('1828553: l_Service_Reference_Line_Id: '||l_Service_Reference_line_id);

            --3273289{
            If(l_Service_Reference_Line_Id is NOT NULL) THEN
            --bug 3968023 to call the procedure Get_The_Parent_Line only if the event contains phase 1
                BEGIN
                    l_event_in_phase1 := 'N';
                    --- bug# 9436193 : Start : using dynamic sql
                    oe_debug_pub.add(' l_event_in_phase1 = '||l_event_in_phase1||'    p_pricing_events  = '||p_pricing_events);
                    l_sql := 'SELECT ''Y''  FROM  qp_pricing_phases p, qp_event_phases e WHERE p.pricing_phase_id=e.pricing_phase_id'
                            ||' AND p.pricing_phase_id = 1 AND trunc(sysdate) BETWEEN trunc(nvl(e.end_date_active,sysdate)) AND trunc(nvl(e.end_date_active,sysdate))'
                            ||' AND e.pricing_event_code in ('''||replace(trim(p_pricing_events),',',''',''')||''') ' ;
                    oe_debug_pub.add(' l_sql = '||l_sql);
                    EXECUTE IMMEDIATE l_sql INTO l_event_in_phase1;
                    oe_debug_pub.add('after l_sql: l_event_in_phase1 =>> '||l_event_in_phase1);
                    /*
                    SELECT 'Y' INTO l_event_in_phase1
                    FROM  qp_pricing_phases p,
                    qp_event_phases e
                    WHERE p.pricing_phase_id=e.pricing_phase_id
                    AND   p.pricing_phase_id = 1
                    AND   e.pricing_event_code= p_pricing_events
                    AND   trunc(sysdate) BETWEEN  trunc(nvl(e.end_date_active,sysdate)) AND   trunc(nvl(e.end_date_active,sysdate));
                    */
                    --- bug# 9436193 : Ends

                    IF l_event_in_phase1 = 'Y' THEN
                        Get_the_parent_Line(p_Reference_line_Id => l_Service_Reference_Line_Id,
                                            p_line_Tbl_Index => line_Tbl_Index,
                                            px_Line_Tbl => l_Line_Tbl) ;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    oe_debug_pub.add(' <exception block>: no_Data_found error ... ');
                    null;

                    WHEN OTHERS THEN
                    oe_debug_pub.add(' <exception block>: SQLERRM ... '|| SQLERRM );
                END;
            --bug 3968023
            END IF;
            --3273289}
        End If; --- IF (OE_Order_PUB.G_LINE.Service_Reference_Line_Id <> FND_API.G_MISS_NUM

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
            oe_debug_pub.add('calling get_prg_lines 5647210 added mass change');
            IF ((p_line_id IS NOT NULL and p_control_rec.p_write_to_db) OR oe_mass_change_pvt.Lines_Remaining = 'Y')
            THEN
                Get_PRG_Lines(l_line_tbl(line_tbl_index).line_id, l_line_tbl, line_tbl_index);
                -- 3529369 In the case  overriding the list price of servicable line the service lines will be
                -- repriced if they are in the same order and service line has an service_reference_type of order
                IF (l_line_tbl(line_tbl_index).item_type_code <> 'SERVICE' AND
                    l_line_tbl(line_tbl_index).calculate_price_flag <> 'X' AND
                    l_line_tbl(line_tbl_index).original_list_price is NOT NULL )
                THEN
                    Get_Service_Lines(l_line_tbl(line_tbl_index).line_id,l_line_tbl(line_tbl_index).header_id, l_line_tbl, line_tbl_index);
                END IF;
            -- 3529369
            END IF;
        END IF;

        -- Get Line Attributes
        G_STMT_NO := 'calculate_adjustments#125';

          -- Set the old item during pricing
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
              Get_item_for_iue(px_line_rec	=> OE_Order_PUB.G_LINE);
        END IF;

        G_STMT_NO := 'calculate_adjustments#135';


        --Set a flag if this line has a calculate flag of N or P
        --which is frozen line. This flag will be used later
        --when passing summary line (order level) to pricing engine
        --with calculate_price of N (do not touch the order level amount).
        IF l_line_tbl(line_tbl_index).item_type_code not in ('CONFIG', 'INCLUDED') THEN
            IF (l_line_tbl(line_tbl_index).calculate_price_flag IN ('N','P')
               AND l_line_tbl(line_tbl_index).cancelled_flag = 'N')
            THEN
               l_any_frozen_line := TRUE;
               x_any_frozen_line := TRUE;
               oe_debug_pub.add('Any frozen line is true');
               IF l_line_tbl(line_tbl_index).calculate_price_flag = 'P' THEN
                l_completely_frozen := FALSE;
               END IF;
            ELSIF l_line_tbl(line_tbl_index).calculate_price_flag = 'Y' THEN
               l_completely_frozen := FALSE;
            END IF;
        END IF;  /* if item type code in ('CONFIG', 'INCLUDED') */


      --RT{
         IF p_pricing_events = 'RETROBILL' and l_line_tbl(line_tbl_index).retrobill_request_id IS NULL
            OR
            p_pricing_events <>  'RETROBILL' and nvl(l_line_tbl(line_tbl_index).retrobill_request_id,FND_API.G_MISS_NUM) <>  FND_API.G_MISS_NUM
         THEN
            --Do nothing for these invalid combinations
            --RETROBILL event must have retrobill_request_id
            --Request None retrobill event with retrobill_request_id should be ignored
            oe_debug_pub.add('VOPRB:event'||p_pricing_events||'retrobill id:'||l_line_tbl(line_tbl_index).retrobill_request_id);
            NULL;
         ELSE
            --RT{
            IF  l_line_tbl(line_tbl_index).retrobill_request_id IS NOT NULL THEN
               --the order has retrobill lines, no header level adjustment should be allowed
               --set following flags so that header level adjustment will not be fetched.
               l_any_frozen_line:=TRUE;
               l_completely_frozen:=FALSE;
            END IF;
            --RT}

            G_STMT_NO := 'Build_Context for Line';
            If l_bypass_pricing = 'Y' OR l_line_tbl(line_tbl_index).calculate_price_flag = 'X' Then
                oe_debug_pub.add('Bypassing the qualifier build',1);
                l_check_line_flag := 'N';
                l_pass_line := 'Y';
                l_line_index := l_line_index + 1;
            Else
                oe_debug_pub.add('Before QP_Attr_Mapping_PUB.Build_Contexts for line',1);
                IF (G_PASS_ALL_LINES = 'R' and
                    NOT OE_LINE_ADJ_UTIL.G_CHANGED_LINE_TBL.exists(mod(l_line_Tbl(line_tbl_index).line_id,G_BINARY_LIMIT))
                    and OE_CODE_CONTROL.Get_Code_Release_Level >= '110509')
                THEN
                  l_check_line_flag := 'Y';
                ELSE
                  l_check_line_flag := 'N';
                END IF;

               --Check_line_flag is to tell QP attr mapping api wether it should
               --check if there is any attribute, that could affect pricing, has changed.
               --if 'Y', QP sourcing api will check.  If there are changes of attribute
               --,which could affect the pricing, it will return x_pass_line = 'Y'. This
               --means we will need to pass this line. If QP return 'N', we will not pass
               --this line to pricing. Copy_line_to_request will not copy the line to pricing
               --request line if QP 'N'.

               --If we pass check_line_flag = 'N' to QP, this means a old behavior (pre I), or
               --we want to force sourcing and repricing of a line. This is usually the case
               --for action-->price_line call in UI.

               --If p_header_id is null means caller tries to price individual line
               --in this case, we should force a reprice of the line. No optimization
               --like to check the l_pass_line is needed #bug 289804100.
               --QP will need to unconditionally build sourcing.
               --BTEA

               oe_debug_pub.add('p_header_id:'||nvl(p_header_id,-100));

               IF p_header_id IS NULL THEN
                    l_check_line_flag := 'N';
               END IF;

                -- bug 3643645
                l_line_index := l_line_index + 1;
                oe_debug_pub.add('before build_context:'||l_line_index, 5);
                QP_Attr_Mapping_PUB.Build_Contexts(
                   p_request_type_code => 'ONT',
                   p_line_index => l_line_index,
                   p_pricing_type_code       =>      'L',
                   p_check_line_flag         => l_check_line_flag,
                   p_pricing_event           => p_pricing_events,
                   x_pass_line               => l_pass_line
                   );
                -- bug 3643645
                IF (l_pass_line = 'N') THEN
                    l_line_index := l_line_index - 1;
                END IF;

                if (l_debug_level > 0) Then
                    oe_debug_pub.add('after build_context:'||l_line_index);
                end if;
            End If;  -- bypass pricing

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('check line'||l_check_line_flag||' pass line:'||l_pass_line);
            END IF;


            If l_check_line_flag = 'N' or l_pass_line = 'Y' Then

                G_STMT_NO := 'calculate_adjustments#140';
               -- AG change
               copy_Line_to_request(
                       p_Line_rec                   => l_Line_Tbl(line_Tbl_Index)
                       ,p_pricing_events            => p_pricing_events
                       ,px_req_line_tbl     => l_req_line_tbl
                       ,p_request_type_code         =>p_control_rec.p_request_type_code
                       ,p_honor_price_flag    =>p_control_rec.p_honor_price_flag
                       ,px_line_index       => l_line_index );
                Begin
                    l_header_id2:=nvl(p_header_id, l_line_tbl(line_tbl_index).header_id);
                    Select 'x' into l_dummy from dual
                    Where exists
                        (select 'x' from oe_order_price_attribs oopa
                            where nvl(oopa.line_id,l_Line_Tbl(line_Tbl_Index).line_id) = l_Line_Tbl(line_Tbl_Index).line_id
                            and oopa.header_id = l_header_id2);


                        -- AG change --
                    Append_asked_for(p_header_id	=> l_header_id2,
                        p_line_id 		=> l_Line_Tbl(line_Tbl_Index).line_id,
                        p_line_index            => 	l_line_index,   --l_req_line_tbl.count
                        px_line_attr_index => l_line_attr_index
                    );
                Exception
                    when no_data_found then null;
                End;
             End If; -- pass line

            -- added by lkxu, to set the value back to 'N' after setting price flag.
            IF l_line_Tbl(line_Tbl_Index).calculate_price_flag = 'X' THEN
                l_line_Tbl(line_Tbl_Index).calculate_price_flag := 'N';
            END IF;
       --End If; -- Item is not Config
        END IF;  --END IF for checking retrobill event and id combination
      --RT}

       line_Tbl_Index := l_Line_Tbl.Next(line_Tbl_Index);

    END LOOP;

-- Get Header Attributes


    G_STMT_NO := 'calculate_adjustments#145';
    -- Build header Request

    G_STMT_NO := 'calculate_adjustments#150';


    IF nvl(p_control_rec.p_honor_price_flag,'Y') = 'N' THEN
    --As per bug 3472375
    -- This affects two cases:
      -- 1. apply line level manual adjustments when every line on the order is set to
      -- frozen and there is an order level adjustment already applied
      -- 2. repricing at shipment, when the workflow attribute honor price flag is set
      -- to "No" and there is an order level adjustment already applied
      -- .
      -- For both cases, we can make the same change, when honor_price_flag is set to
      -- "No", send the price_flag on the summary line as "Y".
      l_calculate_price_flag :='Y';
    ELSE
        IF (l_any_frozen_line=TRUE) THEN

            IF l_completely_frozen = FALSE THEN
              l_calculate_price_flag := 'P';
            ELSE
              l_calculate_price_flag := 'N';
            END IF;

            If Not l_message_displayed Then
              l_message_displayed := TRUE;
            End If;

            l_any_frozen_line:=FALSE;
            oe_debug_pub.add('BCT:ONT_LINE_FROZEN');

        Elsif  l_all_lines_from_db = False Then
            --1472635
            --Didn't query from db, need to do that to check if
            --all other previously save lines is frozen
            oe_debug_pub.add('BCT all line from db is false');

            If p_header_id is null then
              --ine_tbl_index := l_line_tbl.first;
              l_header_id := l_line_tbl(l_line_tbl.first).header_id;
            Else
              l_header_id := p_header_id;
            End If;
            oe_debug_pub.add('BCT order header id '||l_header_id);

            Begin
                BEGIN

                 Select 'x' into l_dummy
                 from dual where
                 exists(select 'x' from oe_order_lines
                        Where header_id = l_header_id
                        and   calculate_price_flag in ('Y','P')
                        and item_type_code not in ('CONFIG', 'INCLUDED'));
                l_completely_frozen := FALSE;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          l_completely_frozen := TRUE;
                          l_any_frozen_line :=True;
                          x_any_frozen_line :=True;
                          l_calculate_price_flag := 'N';
                END;

              IF l_completely_frozen = FALSE THEN
                 Select 'p' into l_dummy
                 from dual where
                 exists (select 'x' from oe_order_lines
                         where header_id = l_header_id
                         and calculate_price_flag in ('N', 'P')
                         and cancelled_flag = 'N'
                         and item_type_code not in ('CONFIG', 'INCLUDED') );

                 l_any_frozen_line := TRUE;
                 x_any_frozen_line := TRUE;
                 l_calculate_price_flag := 'P';
              END IF;

            Exception
                when no_data_found then
                  null;
            End;

            If nvl(l_calculate_price_flag,'X') not in ('N','P') Then
                 l_calculate_price_flag:='Y';
            End If;
        ELSE
           oe_debug_pub.add('BCT:any_frozen_line is false');
           l_calculate_price_flag := 'Y';
        END IF;
    END IF;  --end if for honor price flag check



    -- AG change --
    copy_Header_to_request(
             p_header_rec       => OE_Order_PUB.g_hdr
             ,px_req_line_tbl   =>   l_req_line_tbl
             ,p_Request_Type_Code => p_control_rec.p_Request_Type_Code
             ,p_calculate_price_flag =>l_calculate_price_flag
             ,px_line_index => l_line_index);

    G_STMT_NO := 'Build_Context for Header';
    IF l_bypass_pricing = 'Y' Then
        oe_debug_pub.add('Bypassing the qualifier build',1);
    Else
        oe_debug_pub.add('Before QP_Attr_Mapping_PUB.Build_Contexts for Header',1);
        QP_Attr_Mapping_PUB.Build_Contexts(
                p_request_type_code => 'ONT',
                --p_line_index=>   l_line_index,
                p_line_index=> l_line_index, --oe_order_pub.g_hdr.header_id,
                p_pricing_type_code  =>      'H');

    END IF;

    G_STMT_NO := 'calculate_adjustments#170';

    Begin
    l_header_id2:= nvl(p_header_id,l_line_tbl(l_line_tbl.first).header_id);
    Select 'x' into l_dummy from dual
        where exists(
        Select 'X' from oe_order_price_attribs oopa
        where oopa.header_id = l_header_id2 and oopa.line_id is null);

    -- AG change --
    Append_asked_for(
        p_header_id			=> l_header_id2
        , p_line_id                       => NULL
        ,p_line_index             => l_line_index  --l_req_line_tbl.count
        , px_line_attr_index => l_line_attr_index);
    Exception
        when no_data_found then
            null;
        when others then
            Oe_Debug_Pub.Add('Error when querying asked_for:'||SQLERRM);
    End;

    G_STMT_NO := 'calculate_adjustments#180';
        -- AG change --
    IF l_line_index > 0 THEN
         Populate_Temp_Table;
    END IF;

    x_header_Rec                            :=   OE_Order_PUB.g_hdr;
    px_line_tbl                              :=   l_line_tbl;

EXCEPTION
    when FND_API.G_EXC_ERROR then
        oe_debug_pub.add('error in calculate adjustments'||G_STMT_NO, 2);
        RAISE FND_API.G_EXC_ERROR;
    when others then
        oe_debug_pub.add('others error in calculate adjustments'||G_STMT_NO,2);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Calculate_Adjustments;






Procedure Call_Pricing_Engine(
   p_Control_Rec IN OE_ORDER_PRICE_PVT.control_rec_type
  ,p_Pricing_Events IN VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status_text varchar(2000);
l_control_rec QP_PREQ_GRP.control_record_type;
l_set_of_books Oe_Order_Cache.Set_Of_Books_Rec_Type;
/*
l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
l_pricing_contexts_Tbl		  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_qualifier_contexts_Tbl		  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
x_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
x_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
x_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
x_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
x_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
x_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
x_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
*/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE QP_PREQ_PUB.PRICE_REQUEST' , 1 ) ;
	END IF;

            l_control_rec.calculate_flag := p_control_rec.p_calculate_flag;
            l_control_rec.simulation_flag := p_control_rec.p_simulation_flag;
            l_control_rec.pricing_event := p_Pricing_Events;
            l_control_rec.temp_table_insert_flag := 'N';
            l_control_rec.check_cust_view_flag := 'Y';
            l_control_rec.request_type_code := p_control_rec.p_request_type_code;
            --now pricing take care of all the roundings.
            l_control_rec.rounding_flag := 'Q';
            --For multi_currency price list
            l_control_rec.use_multi_currency:='Y';
            l_control_rec.USER_CONVERSION_RATE:= OE_ORDER_PUB.G_HDR.CONVERSION_RATE;
            l_control_rec.USER_CONVERSION_TYPE:= OE_ORDER_PUB.G_HDR.CONVERSION_TYPE_CODE;
            l_set_of_books := Oe_Order_Cache.Load_Set_Of_Books;
            l_control_rec.FUNCTION_CURRENCY   := l_set_of_books.currency_code;

	    If l_Control_Rec.pricing_event IN ('BATCH','RETROBILL') OR
               nvl(instr( l_Control_Rec.pricing_event,'BATCH'),0) > 0
	    Then
                   l_control_rec.source_order_amount_flag := 'Y';
            End If;

            -- added for freight rating.
            l_control_rec.get_freight_flag := p_control_rec.p_get_freight_flag;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('get_freight_flag before calling pricing engine is: '||l_control_rec.get_freight_flag, 3 ) ;
	    END IF;

            IF (G_PASS_ALL_LINES in ('N', 'R')) THEN
              l_control_rec.full_pricing_call := 'N';
            ELSE
              l_control_rec.full_pricing_call := 'Y';
            END IF;
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
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
	         RAISE FND_API.G_EXC_ERROR;
   	      END IF;

END Call_Pricing_Engine;



procedure pricing_errors_hold(
   p_header_id             number
  ,p_line_id               number
  , pmsg                varchar2
)

is
l_hold_source_rec  OE_Holds_Pvt.hold_source_rec_type;
l_return_status                 varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                  Varchar2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

begin

           l_hold_source_rec.hold_id := G_SEEDED_PRICE_ERROR_HOLD_ID;
           l_hold_source_rec.hold_entity_id := p_header_id;
           l_hold_source_rec.Hold_Entity_code := 'O';
           l_hold_source_rec.header_id := p_header_id;
           l_hold_source_rec.line_id := p_line_id;
         IF l_debug_level  > 0 THEN
          oe_debug_pub.add('p_line_id = '||p_line_id,1);
         END IF;

     OE_Holds_Pub.Check_Holds(
        p_api_version           => 1.0
       ,p_header_id             => p_header_id
       ,p_line_id               => p_line_id
       ,p_hold_id               => l_hold_source_rec.Hold_id
       ,p_wf_item               => 'OEOL'
       ,p_wf_activity           => 'INVENTORY_INTERFACE'
       ,x_return_status         => l_return_status
       ,x_msg_count             => l_x_msg_count
       ,x_msg_data              => l_x_msg_data
       ,x_result_out            => l_x_result_out

        );

         IF (l_return_status <> FND_API.g_ret_sts_success) THEN
           IF l_debug_level  > 0 THEN
    oe_debug_pub.add(' OE_HOLD_PUB.Check_Holds returns unexpected error!');
           END IF;
    RAISE FND_API.G_EXC_ERROR;
        null;
        END IF;
             IF l_x_result_out = FND_API.G_FALSE THEN
                           OE_HOLDS_PUB.Apply_Holds(
          p_api_version         => 1.0
          ,p_hold_source_rec    => l_hold_source_rec
        --  ,p_header_id          => l_line_rec.header_id
        --  ,p_line_id               => l_line_rec.line_id
          ,x_return_status      => l_return_status
          ,x_msg_count          => l_x_msg_count
          ,x_msg_data           => l_x_msg_data
          );
            END IF;

IF l_return_status = FND_API.g_ret_sts_success then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('just before showing formula error',1);
    END IF;

                FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR_HOLD');
                FND_MESSAGE.SET_TOKEN('ERR_TEXT',pmsg);
                OE_MSG_PUB.Add;
End if;
exception
    WHEN FND_API.G_EXC_ERROR then
      null;
end;



Function get_formula(p_line_index In Number) Return Varchar2 IS
   Cursor Get_Formula Is
   Select f.formula
   From   qp_ldets_v ldet, qp_list_lines qpll, qp_price_formulas_vl f
   Where  ldet.line_index = p_line_index
   AND    ldet.list_line_id = qpll.list_line_id
   AND    f.price_formula_id = nvl(qpll.price_by_formula_id,qpll.generate_using_formula_id);
   l_formula_name Varchar2(2000);
Begin
     open get_formula;
     fetch get_formula into l_formula_name;
     return l_formula_name;
     close get_formula;
Exception
   when no_data_found then
      oe_debug_pub.add('Formula name not found for the errorneous formula');
      return null;
End;

procedure Report_Engine_Errors(
x_return_status out nocopy Varchar2

,  p_Control_Rec	IN   OE_ORDER_PRICE_PVT.Control_rec_type
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
l_list_line_no Varchar2(2000);
--bug 3696768
cursor reset_ipl_tbl is
  select line_id
  from qp_preq_lines_tmp
  where pricing_status_code <> QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST;
--bug 3696768
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
       , lines.line_index
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
 --bug 3968023
   and lines.pricing_status_code <> QP_PREQ_PUB.G_STATUS_UNCHANGED
   ;
   -- Bug 2079138: booked lines should always have price
   --and lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_UPDATED
   --                              , QP_PREQ_GRP.G_STATUS_GSA_VIOLATION
   --                                  );
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --

   l_booking_error varchar2(1) := 'N'; -- Bug 8236945
begin
-- Update Order Lines
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.REPORT_ENGINE_ERROR' , 1 ) ;
	END IF;
  --bug 3696768
  IF G_IPL_ERRORS_TBL.count <> 0 THEN
    FOR I in reset_ipl_tbl LOOP
      IF (G_IPL_ERRORS_TBL.exists(MOD(I.line_id,G_BINARY_LIMIT))) THEN
        G_IPL_ERRORS_TBL.delete(MOD(I.line_id,G_BINARY_LIMIT));
      END IF;
    END LOOP;
  END IF;
  --bug 3696768
	G_STMT_NO := 'Report_Engine_Error#10';

   For wrong_line in wrong_lines loop  --i:=  p_req_line_tbl.first;

	 If px_Line_Tbl.count = 0 Then
		Begin

                      Query_line
		      (   p_Line_id             => wrong_line.line_id
                      ,   x_line_rec            => l_line_rec);
		    Exception when no_data_found then
                         null;
			 IF l_debug_level  > 0 THEN
			     oe_debug_pub.add(  'REPORT_ENGINE_ERROR QUERY_LINE , NO DATA FOUND' ) ;
			 END IF;
		End;
	 Else
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
	End If;

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
	/*IF wrong_line.line_Type_code ='LINE' and
		wrong_line.processed_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND Then
	           IF not G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id,G_BINARY_LIMIT))
                       or (G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id,G_BINARY_LIMIT))
                           and
                           G_IPL_ERRORS_TBL(MOD(l_line_rec.line_id,G_BINARY_LIMIT))<>l_line_rec.price_list_id)
		   Then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'PRICE LIST NOT FOUND' ) ;
		 	END IF;
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'INVALID PRICE LIST ' , 1 ) ;
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
                        ELSE
		  	     OE_MSG_PUB.Add;
                        END IF;
                  END IF;
           l_invalid_line := 'Y';
        END IF; */

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


			IF not G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id,G_BINARY_LIMIT))
                         or (G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id,G_BINARY_LIMIT))
                             and
                             G_IPL_ERRORS_TBL(MOD(l_line_rec.line_id,G_BINARY_LIMIT))<>l_line_rec.price_list_id)
			Then

		 	       FND_MESSAGE.SET_NAME('ONT','OE_PRC_NO_LIST_PRICE');
		 	       FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	       FND_MESSAGE.SET_TOKEN('UNIT',l_line_rec.Order_Quantity_uom);
		 	       FND_MESSAGE.SET_TOKEN('PRICE_LIST',l_Price_List);
			       IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
                                IF l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                                   vmsg := FND_MESSAGE.GET;
                                ELSE
                                   OE_MSG_PUB.Add;
                                END IF;
                               ELSE
		  	           OE_MSG_PUB.Add;
                               END IF;
			 ELSE
			       l_invalid_line := 'N';
			 End IF;

			 IF l_line_rec.price_list_id IS NOT NULL THEN
			   G_IPL_ERRORS_TBL(MOD(l_line_rec.line_id,G_BINARY_LIMIT)):=l_line_rec.price_list_id;
			 END IF;

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
                            -- Bug 8236945
                            IF OE_GLOBALS.G_UI_FLAG THEN
                               RAISE FND_API.G_EXC_ERROR;
                            ELSE
                               l_booking_error := 'Y';
                            END IF;
                         End If;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'PRICE'||L_LINE_REC.UNIT_SELLING_PRICE||':'||L_LINE_REC.UNIT_LIST_PRICE ) ;
                        END IF;

                        --Fix bug 1650637
                        If (l_line_rec.unit_selling_price Is Not Null or
                            l_line_rec.unit_list_price Is Not Null
                           ) AND NOT (p_control_rec.p_write_to_db)
                        THEN
                            l_line_rec.unit_selling_price := NULL;
                            l_line_rec.unit_selling_price_per_pqty := NULL;
                            l_line_rec.unit_list_price := NULL;
                            l_line_rec.unit_list_price_per_pqty := NULL;
                        END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add('invalid price done');
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
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text||','||get_formula(wrong_line.line_index));
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
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
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
                 If Not p_control_rec.p_write_to_db Then
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
                 End If;
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
		 l_list_line_no:=get_list_lines(wrong_line.line_id);

		 IF l_list_line_no IS NOT NULL THEN
                   FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_MODIFIERS');
                   FND_MESSAGE.SET_TOKEN('LIST_LINE_NO',get_list_lines(wrong_line.line_id));
                   OE_MSG_PUB.Add;
		 END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'MODIFIERS:'||GET_LIST_LINES ( WRONG_LINE.LINE_ID ) ) ;
                 END IF;

		 --place the line on invoicing hold to avoid stuck order it the ship quatity is there.
		 IF l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM THEN
		    vmsg := FND_MESSAGE.GET;
                    oe_debug_pub.add('vmsg = '||vmsg,1);
                    pricing_errors_hold(l_line_rec.header_id,l_line_rec.line_id,vmsg);
                    -- select oe_msg_request_id_s.nextval into l_request_id from dual;
                    -- OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, l_request_id,'U');
                    --  4919922
                    IF (OE_GLOBALS.G_UI_FLAG ) THEN
                      IF (G_REQUEST_ID IS NULL) THEN
                        select oe_msg_request_id_s.nextval into g_request_id from dual;
                      END IF;
                      OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
                    END IF;

		 ELSE
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;

        end if;

	IF wrong_line.line_type_code='ORDER'  THEN
           if wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_FORMULA_ERROR then
                oe_debug_pub.add(  'ERROR IN ORDER LEVEL FORMULA PROCESSING' ) ;
	 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_ERROR_IN_FORMULA');
		FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text||','||get_formula(wrong_line.line_index));
		OE_MSG_PUB.Add;
		vmsg := FND_MESSAGE.GET;
	   else
	        oe_debug_pub.add(  'OTHER ERRORS PROCESSING' ) ;
		FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
	 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text);
		OE_MSG_PUB.Add;
		vmsg := FND_MESSAGE.GET;
	   end if;
        END IF;   --end if for 'ORDER' line_type_code

     If l_invalid_line = 'Y' Then
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('vmsg = '||vmsg,1);
        END IF;
        pricing_errors_hold(l_line_rec.header_id,l_line_rec.line_id,vmsg);
        -- select oe_msg_request_id_s.nextval into l_request_id from dual;

        -- OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, l_request_id,'U');
        --  4919922
        IF (OE_GLOBALS.G_UI_FLAG ) THEN
          IF (G_REQUEST_ID IS NULL) THEN
            select oe_msg_request_id_s.nextval into g_request_id from dual;
          END IF;
          OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
        END IF;

       else
	 oe_debug_pub.add('has invalid line');
        l_temp_line_rec.line_id := Wrong_line.line_id;
	 oe_debug_pub.add('has invalid line2');
        l_temp_line_rec.ordered_quantity := Wrong_line.line_quantity;
	 oe_debug_pub.add('has invalid line3');
        l_temp_line_rec.pricing_quantity := Wrong_line.priced_quantity;
	 oe_debug_pub.add('has invalid line4');
        -- select oe_msg_request_id_s.nextval into l_request_id from dual;

        -- OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, l_request_id,'U');
        --  4919922
        IF (OE_GLOBALS.G_UI_FLAG ) THEN
          IF (G_REQUEST_ID IS NULL) THEN
            select oe_msg_request_id_s.nextval into g_request_id from dual;
          END IF;
          OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
        END IF;

	 oe_debug_pub.add('has invalid line 5');
        Oe_Order_Adj_Pvt.Reset_Fields(l_temp_line_rec);
       end if;
     else
        l_temp_line_rec.line_id := Wrong_line.line_id;
        l_temp_line_rec.ordered_quantity := Wrong_line.line_quantity;
        l_temp_line_rec.pricing_quantity := Wrong_line.priced_quantity;
        -- select oe_msg_request_id_s.nextval into l_request_id from dual;

        -- OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, l_request_id,'U');
        --  4919922
        IF (OE_GLOBALS.G_UI_FLAG ) THEN
          IF (G_REQUEST_ID IS NULL) THEN
            select oe_msg_request_id_s.nextval into g_request_id from dual;
          END IF;
          OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
        END IF;

        Oe_Order_Adj_Pvt.Reset_Fields(l_temp_line_rec);
     end if;
     Else
        oe_debug_pub.add('No invalid line');
        l_invalid_line:='N';
     End If;

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
        pricing_errors_hold(book_line.header_id,book_line.line_id,vmsg);
       else
        OE_MSG_PUB.ADD;
        l_temp_line_rec.line_id := book_line.line_id;
        l_temp_line_rec.ordered_quantity := book_line.line_quantity;
        l_temp_line_rec.pricing_quantity := book_line.priced_quantity;
        Oe_Order_Adj_Pvt.Reset_Fields(l_temp_line_rec);
        -- Bug 8236945
        IF OE_GLOBALS.G_UI_FLAG THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           l_booking_error := 'Y';
        END IF;
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
       -- Bug 8236945
       IF OE_GLOBALS.G_UI_FLAG THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          l_booking_error := 'Y';
       END IF;
  END IF;

End loop; /* wrong booked lines */
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING REPORT_ENGINE_ERRORS' ) ;
     END IF;

     -- Added for bug 8236945
     IF l_booking_error = 'Y' THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     -- End of bug 8236945
End Report_Engine_Errors;

procedure process_adjustments
(
x_return_status out nocopy Varchar2,

p_Control_Rec                      OE_ORDER_PRICE_PVT.Control_rec_type,
p_any_frozen_line              in              Boolean,
px_line_Tbl                     in out NOCOPY    oe_Order_Pub.Line_Tbl_Type,
p_header_id                     in number,
p_line_id                       in number,
p_header_rec                               oe_Order_Pub.header_rec_type,
p_pricing_events                in varchar2
)
is
l_line_rec                              oe_order_pub.line_rec_type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
i                                               pls_Integer;
j                                               pls_Integer;
l_price_list                            Varchar2(240);
l_allow_negative_price          Varchar2(30) := nvl(fnd_profile.value('ONT_NEGAT
IVE_PRICING'),'N');
l_sec_result     NUMBER;
l_adjustment_count NUMBER:=0;
l_old_line_tbl   OE_ORDER_PUB.Line_Tbl_Type;
l_num_changed_lines NUMBER := 0;
l_process_requests BOOLEAN := FALSE;
l_process_ack BOOLEAN := FALSE;
l_notify_flag  BOOLEAN;
l_booked_flag  varchar2(1) := oe_order_cache.g_header_rec.booked_flag;
l_return_status                 VARCHAR2(30);
l_msg_count                             NUMBER;
l_msg_data                              VARCHAR2(2000);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SAVEPOINT PROCESS_ADJUSTMENTS;
  l_old_line_tbl := px_line_Tbl;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Report_Engine_Errors(x_return_status
                   ,   p_control_rec
                   ,   px_line_tbl
                   ,   p_header_rec);
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_control_rec.p_write_to_db THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WRITING TO DATABASE' , 3 ) ;
    END IF;

    CHECK_GSA;

    UPDATE_ORDER_HEADER(p_header_rec);

  /*  UPDATE_ORDER_LINES(px_line_tbl
                      , l_num_changed_lines); moved after oe_adv_price_pvt.process_adv_modifiers */

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALLING OE_ADV_PRICE_PVT.PROCESS_ADV_MODIFIERS:'||OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL ) ;
         END IF;
         oe_adv_price_pvt.process_adv_modifiers
         (x_return_status => x_return_status,
          p_Control_Rec   => p_Control_Rec,
          p_any_frozen_line => p_any_frozen_line,
          px_line_Tbl     => px_line_Tbl,
          px_old_line_Tbl => l_old_line_Tbl,
          p_header_id     => p_header_id,
          p_line_id       => p_line_id,
          p_header_rec    => p_header_rec,
          p_pricing_events => p_pricing_events);
     END IF;

     UPDATE_ORDER_LINES(px_line_tbl
                       ,l_num_changed_lines
                       ,p_control_rec.p_write_to_db);

         -- Performance change for Legato
         -- Not refresh order when no attributes changed
         -- Freight charge change doesn't result in line change

--         If p_pricing_events in ('ORDER','SHIP','BOOK') then
  --changes to enable multiple events passed as a string
                IF instr(p_pricing_events||',', 'ORDER,') > 0
                OR instr(p_pricing_events||',', 'SHIP') > 0
                OR instr(p_pricing_events||',', 'BOOK') > 0
                OR instr(p_pricing_events||',', 'BATCH') > 0 then
           IF (l_num_changed_lines > 0) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING CASCADING FLAG TO REFRESH ORDER' ) ;
            END IF;
            OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
           END IF;
         End if;

   -- calculate may change adjustments: adjusted_amount
   --IF (p_control_rec.p_calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY) THEN
    IF (p_header_id IS NOT NULL) THEN
      REFRESH_ADJS(p_line_id=>NULL
               ,   p_pricing_events=>p_pricing_events
               ,   p_calculate_flag => p_control_rec.p_calculate_flag);
    ELSIF (p_line_id IS NOT NULL) THEN
      REFRESH_ADJS(p_line_id => p_line_id
               ,   p_pricing_events => p_pricing_events
               ,   p_calculate_flag => p_control_rec.p_calculate_flag);
    ELSE
      i := px_line_tbl.FIRST;
      WHILE i IS NOT NULL LOOP
        REFRESH_ADJS(p_line_id=>px_line_tbl(i).line_id
                 ,   p_pricing_events=>p_pricing_events
                 ,   p_calculate_flag => p_control_rec.p_calculate_flag
                 ,   p_header_id => px_line_tbl(i).header_id);
        i := px_line_tbl.next(i);
      END LOOP;
    END IF;
   --END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'VOPRB RECURSION MODE'||OE_GLOBALS.G_RECURSION_MODE ) ;
  END IF;

  -- 2366123: execute delayed requests only when not called by UI
  --  IF (OE_GLOBALS.G_RECURSION_MODE <> FND_API.G_TRUE
     IF (NOT OE_GLOBALS.G_UI_FLAG AND p_control_rec.p_write_to_db = TRUE AND l_num_changed_lines > 0 ) THEN
       l_process_requests := TRUE;
       l_old_line_tbl := px_line_tbl;
     END IF;

  IF (p_control_rec.p_write_to_db = FALSE)
   THEN
     POPULATE_LINE_TBL(px_line_tbl);
  END IF;

   IF l_process_requests THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'VOPRB BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
       END IF;

       IF (oe_order_cache.g_header_rec.booked_flag = 'Y') Then
         l_process_ack := TRUE;
       END IF;

                    OE_Order_PVT.Process_Requests_And_Notify
                        ( p_process_requests          => TRUE
                        , p_notify                    => l_process_ack
                        , p_process_ack               => l_process_ack
                        , x_return_status             => x_return_status
                        , p_line_tbl                  => px_line_tbl
                        , p_old_line_tbl              => l_old_line_tbl
                        );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETRURNED FROM PROCESS_REQUEST AND NOTIFY : '||X_RETURN_STATUS , 3 ) ;
      END IF;

                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                    RAISE FND_API.G_EXC_ERROR;
                    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
  END IF;

/*AS per Jyothi Narayan, Process_Requests_And_Notify has notify call. No extra call is needed
   If l_debug_level  > 0 THEN
     oe_debug_pub.add('l_booked_flag in process_adjustments = '||l_booked_flag);   End If;
IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
 IF l_booked_flag = 'Y' AND p_control_rec.p_write_to_db = TRUE THEN
  IF NOT OE_GLOBALS.G_UI_FLAG AND OE_GLOBALS.G_RECURSION_MODE = 'N' THEN
    If l_debug_level  > 0 THEN
     oe_debug_pub.add('Before calling OE_SERVICE_UTIL.Notify_OC in process adj');

    End If;
     OE_SERVICE_UTIL.Notify_OC
    (   p_api_version_number                  =>  1.0
    ,   p_init_msg_list                       =>  FND_API.G_FALSE
    ,   x_return_status                       =>  l_return_status
    ,   x_msg_count                           =>  l_msg_count
    ,   x_msg_data                            =>  l_msg_data
    ,   p_Line_Adj_tbl                        =>  OE_ORDER_UTIL.g_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl                    =>  OE_ORDER_UTIL.g_old_Line_Adj_tbl);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER NOTIFY_OC API' , 1 ) ;
       END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

  END IF;
END IF; */


Exception
            WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'EXITING PROCESS_ADJUSTMENTS WITH EXC ERROR with rollback' , 1 ) ;
                END IF;
                ROLLBACK TO SAVEPOINT PROCESS_ADJUSTMENTS;

                 RAISE FND_API.G_EXC_ERROR;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'EXITING PROCESS_ADJUSTMENTS WITH UNEXPECTED ERROR with rollback' , 1 ) ;
                        END IF;
                    ROLLBACK TO SAVEPOINT PROCESS_ADJUSTMENTS;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'ERROR IN OE_ORDER_PRICE_PVT.PROCESS_ADJUSTMENTS with rollback' , 1 ) ;
                        END IF;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  SQLERRM , 1 ) ;
                        END IF;

                        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                OE_MSG_PUB.Add_Exc_Msg
                                (   G_PKG_NAME
                                ,   'Process_Adjustments',
                                        sqlerrm
                                );
                        END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.PROCESS_ADJUSTMENTS with rollback' , 1 ) ;
                        END IF;
                        ROLLBACK TO SAVEPOINT PROCESS_ADJUSTMENTS;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.PROCESS_ADJUSTMENTS' , 1 ) ;
  END IF;
END Process_Adjustments;

-- Price_Line is the main Pricing Integration API
-- It can be used to Price an order, an order line, or multiple lines
Procedure Price_line(
		 p_Header_id        	IN NUMBER
		,p_Line_id          	IN NUMBER
		,px_line_Tbl	        IN OUT NOCOPY   oe_Order_Pub.Line_Tbl_Type
		,p_Control_Rec		IN OE_ORDER_PRICE_PVT.control_rec_type
                ,p_action_code          IN VARCHAR2
                ,p_Pricing_Events       IN VARCHAR2
--RT{
                ,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC
--RT}
,x_Return_Status OUT NOCOPY VARCHAR2

                )
is
l_any_frozen_line BOOLEAN;
lx_header_rec OE_ORDER_PUB.HEADER_REC_TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('Version:'||get_version);
   END IF;

   --RT{
   G_PRICING_EVENT:=p_pricing_events;
   G_RETROBILL_OPERATION:=p_request_rec.param3;

   oe_debug_pub.add('Retrobill Operation:'||g_retrobill_operation);
   --RT}

   If OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE Then
    G_DEBUG := TRUE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BCT G_DEBUG IS:'||OE_DEBUG_PUB.G_DEBUG ) ;
    END IF;
   Else
    G_DEBUG := FALSE;
   End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SETTING REQUEST ID' , 1 ) ;
   END IF;

   qp_price_request_context.set_request_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' REQUEST ID IS : ' || QP_PREQ_GRP.G_REQUEST_ID , 1 ) ;
   END IF;

   G_IS_THERE_FREEZE_OVERRIDE:=TRUE;
   G_IS_THERE_FREEZE_OVERRIDE:=Check_Freeze_Override(p_pricing_events);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE_LINE:'||P_HEADER_ID||'+'||P_LINE_ID||'OF EVENT '||P_PRICING_EVENTS , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

calculate_adjustments
(x_return_status 		=>  x_return_status,
p_line_Id         		=>  p_line_Id,
p_header_Id			=>  p_Header_Id,
p_pricing_events                => p_pricing_events,
p_Control_Rec			=> p_control_rec,
p_action_code                   => p_action_code,
x_any_frozen_line        => l_any_frozen_line,
px_line_Tbl			=> px_Line_Tbl,
x_Header_Rec			=> lx_Header_Rec
);


--l_Control_Rec.calculate_flag := 'N';
-- Do no proceed , if there are no order lines
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALCULATE ADJUSTMENTS ERROR' ) ;
         END IF;
         raise fnd_api.g_exc_error;
    END IF;

If x_return_status = 'NOOP' Then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'THERE ARE NO ORDER LINES FOR '||P_LINE_ID ) ;
	END IF;
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;
	Return;
End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALLING PRICING ENGINE PUBLIC API' , 2 ) ;
   END IF;
   Call_Pricing_Engine(p_Control_Rec
                      ,p_Pricing_Events
                      ,x_return_status
                      );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PRICING ENGINE ERROR' ) ;
         END IF;
         raise fnd_api.g_exc_error;
    END IF;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'BEFORE OE_ORDER_PRICE_PVT.PROCESS_ADJUSTMENTS' , 1 ) ;
END IF;

process_adjustments
	  (
	  x_return_status    	=> x_Return_Status,
	  p_Control_Rec         => p_control_rec,
          p_any_frozen_line     =>l_any_frozen_line,
	  p_Header_Rec		=> lx_Header_Rec,
          p_header_id           => p_header_id,
          p_line_id             => p_line_id,
	  px_line_Tbl		=> px_Line_Tbl,
          p_pricing_events      => p_pricing_events
	  );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PROCESS ADJUSTMENTS ERROR' ) ;
         END IF;
         raise fnd_api.g_exc_error;
    END IF;
                --reseting global structure after engine call
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.PRICE_LINE' , 1 ) ;
	END IF;

	Exception
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
       oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.PRICE_LINE' , 1 ) ;
   END IF;

End Price_Line;

end OE_ORDER_PRICE_PVT;

/
