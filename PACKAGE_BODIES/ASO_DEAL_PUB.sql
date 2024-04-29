--------------------------------------------------------
--  DDL for Package Body ASO_DEAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEAL_PUB" as
/* $Header: asoidmib.pls 120.9 2008/07/11 10:08:01 rassharm noship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_DEAL_PUB';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoidmib.pls';


-- Start of Comments
-- Package name : ASO_DEAL_PUB
-- Purpose      : API methods for implementing Deal Management Integration
-- End of Comments



Procedure Update_Quote_From_Deal
 (  P_Quote_Header_Id            IN   NUMBER,
    P_resource_id                IN   NUMBER,
    P_event                      IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 )
is

-- for fetching status id
CURSOR C_qte_status_id (pc_quote_status_code VARCHAR2)
	IS
	  SELECT quote_status_id
	   FROM aso_quote_statuses_b
	   WHERE status_code = pc_quote_status_code;

-- for fetching quote header details
CURSOR C_quote_header(pc_quote_header_id NUMBER)
IS
  SELECT last_update_date, quote_number, max_version_flag, pricing_status_indicator, tax_status_indicator,quote_status_id,price_request_id
	FROM aso_quote_headers_all
	WHERE quote_header_id = pc_quote_header_id;


-- for fetching line level details
CURSOR C_quote_line(pc_quote_line_id NUMBER)
	IS
	SELECT  aqla.line_quote_price,aqla.quantity, nvl(aship.ship_method_code,'X') ship_method_code,nvl(payment_term_id,-1) payment_term_id,nvl(PRICING_LINE_TYPE_INDICATOR,'XXX') PRICING_LINE_TYPE_INDICATOR
	FROM aso_quote_lines_all aqla, aso_shipments aship,aso_payments apay
	WHERE aqla.quote_line_id = pc_quote_line_id
	AND  aqla.quote_line_id = aship.quote_line_id (+)
	AND  aqla.quote_line_id = apay.quote_line_id (+) ;


-- for fetching already applied adjustment except deal adjustment
cursor cur_app_adj(pc_quote_header_id NUMBER,pc_quote_line_id NUMBER,pc_modifier_line_id NUMBER)
IS
SELECT
	  PRICE_ADJUSTMENT_ID,
          PRICE_BREAK_TYPE_CODE,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
           nvl(OPERAND_PER_PQTY,OPERAND) operand,
           MODIFIED_FROM,
           MODIFIED_TO,
           UPDATE_ALLOWABLE_FLAG,
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           RANGE_BREAK_QUANTITY,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT,
	   adjusted_amount,
	   automatic_flag
            from aso_price_adjustments
           where quote_header_id=pc_quote_header_id
           and quote_line_id =pc_quote_line_id
           and applied_flag='Y'
	   and modifier_line_id<>nvl(pc_modifier_line_id,-1)
           AND nvl(expiration_date,sysdate) >= sysdate;




l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_QUOTE_FROM_DEAL';
l_api_version_number     CONSTANT NUMBER   := 1.0;
p_api_version_number     CONSTANT NUMBER   := 1.0;
p_init_msg_list          VARCHAR2(1)     := FND_API.G_TRUE;

l_access_level           VARCHAR2(10);
l_db_link		 varchar2(240);
l_quote_line_id          NUMBER;
l_updated_line_price     NUMBER;
l_line_quote_price       NUMBER;
i                        NUMBER:=0; -- line index
s_index                  NUMBER:=0; -- shipment index
p_index                  NUMBER:=0; -- price adjustment index
pa_index                 NUMBER:=0; -- payment term index

l_sqlstmt                VARCHAR2(1000);
l_modifier_line_profile  VARCHAR2(30);
l_continue		 VARCHAR2(1);
l_count_modifier         NUMBER:=0;
l_uom_code               varchar2(30);
l_currency_code          varchar2(30);
l_ordered_qty            NUMBER;
l_line_qty               NUMBER;
l_modifier_name          varchar2(240);
ln_count                 NUMBER:=0;
l_pricing_line_type_indicator ASO_QUOTE_LINES_ALL.PRICING_LINE_TYPE_INDICATOR%type;

-- For multi-row query dynamic execution
TYPE PRCCURREF is REF CURSOR;
prcadj_cv         PRCCURREF;

l_last_update_date        ASO_QUOTE_HEADERS_ALL.last_update_date%TYPE;
l_quote_number            ASO_QUOTE_HEADERS_ALL.quote_number%TYPE;
l_max_version_flag        ASO_QUOTE_HEADERS_ALL.max_version_flag%TYPE;
l_pricing_status          ASO_QUOTE_HEADERS_ALL.PRICING_STATUS_INDICATOR%TYPE;
l_tax_status              ASO_QUOTE_HEADERS_ALL.TAX_STATUS_INDICATOR%TYPE;
l_quote_status_id         ASO_QUOTE_HEADERS_ALL.QUOTE_STATUS_ID%TYPE;
ln_quote_status_id        ASO_QUOTE_HEADERS_ALL.QUOTE_STATUS_ID%TYPE;
ld_quote_status_id        ASO_QUOTE_HEADERS_ALL.QUOTE_STATUS_ID%TYPE;
l_price_request_id        ASO_QUOTE_HEADERS_ALL.PRICE_REQUEST_ID%TYPE;
l_payment_term_id         ASO_PAYMENTS.PAYMENT_TERM_ID%TYPE;
l_line_payment_term_id    ASO_PAYMENTS.PAYMENT_TERM_ID%TYPE;
l_shipment_method_code    ASO_SHIPMENTS.SHIP_METHOD_CODE%TYPE;
l_line_ship_method_code   ASO_SHIPMENTS.SHIP_METHOD_CODE%TYPE;
L_modifier_line_id        ASO_PRICE_ADJUSTMENTS.MODIFIER_LINE_ID%TYPE;
l_price_adjustment_id     ASO_PRICE_ADJUSTMENTS.PRICE_ADJUSTMENT_ID%TYPE;
l_applied_flag            ASO_PRICE_ADJUSTMENTS.APPLIED_FLAG%TYPE;
l_operand                 ASO_PRICE_ADJUSTMENTS.OPERAND%TYPE;
ld_operand                ASO_PRICE_ADJUSTMENTS.OPERAND%TYPE;


l_control_rec             ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;
l_qte_header_rec          ASO_QUOTE_PUB.qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;

l_qte_line_rec            ASO_QUOTE_PUB.Qte_Line_Rec_Type:=ASO_QUOTE_PUB.G_MISS_Qte_Line_Rec;
l_qte_line_tbl            ASO_QUOTE_PUB.QTE_LINE_Tbl_Type;

l_ln_Payment_rec          ASO_QUOTE_PUB.Payment_Rec_Type:=ASO_QUOTE_PUB.G_MISS_PAYMENT_rec;
l_ln_Payment_Tbl	  ASO_QUOTE_PUB.Payment_Tbl_Type:=   ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_ln_Payment_Tbl1	  ASO_QUOTE_PUB.Payment_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;

l_ln_Shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type:=ASO_QUOTE_PUB.G_MISS_shipment_rec;
l_ln_Shipment_Tbl	  ASO_QUOTE_PUB.Shipment_Tbl_Type:=  ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
l_ln_Shipment_Tbl1	  ASO_QUOTE_PUB.Shipment_Tbl_Type:=  ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;

l_price_adj_rec           ASO_QUOTE_PUB.Price_Adj_Rec_Type:= ASO_QUOTE_PUB.G_MISS_Price_Adj_REC ;
l_Price_Adjustment_Tbl    ASO_QUOTE_PUB.Price_Adj_Tbl_Type:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;



--

 lx_qte_header_rec         ASO_QUOTE_PUB.Qte_Header_Rec_Type;
 lx_qte_line_tbl           ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
 lx_qte_line_dtl_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
 lx_hd_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 lx_hd_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
 lx_hd_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
 lx_hd_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 lx_hd_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

 lx_Line_Attr_Ext_Tbl      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
 lx_line_rltship_tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
 lx_Price_Adjustment_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
 lx_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
 lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
 lx_ln_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 lx_ln_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
 lx_ln_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
 lx_ln_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 lx_ln_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

 l_file                  VARCHAR2(200); -- for log generation

 l_len_sqlerrm Number ;   -- For error handling
 l_err number := 1;       -- For error handling

BEGIN


  aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
   --pp_debug('In update deal'|| aso_debug_pub.g_debug_flag);
  if  aso_debug_pub.g_debug_flag='Y' then -- enabling trace
   aso_debug_pub.SetDebugLevel(10);
   aso_debug_pub.Initialize;
   l_file    := ASO_DEBUG_PUB.Set_Debug_Mode('FILE');
    --pp_debug('In update deal'|| l_file);
   aso_debug_pub.debug_on;
  end if;

   --pp_debug('In update deal'|| aso_debug_pub.g_debug_flag);
  IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB: ****** Start of Update_Quote_From_Deal API ******', 1, 'Y');
  END IF;

  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --

	--pp_debug('Event:' || p_event);
	--pp_debug('Resource_id' || p_resource_id);
	--pp_debug('Quote num: ' || p_quote_header_id);
	--pp_debug('event'||p_event);
  -- API body
  IF P_event in ('SUBMITTED', 'CANCELED', 'ACCEPTED') then
    open C_quote_header (p_quote_header_id);
    FETCH C_quote_header INTO l_last_update_date, l_quote_number, l_max_version_flag, l_pricing_status, l_tax_status,l_quote_Status_id,l_price_request_id;
    close C_quote_header;

    --pp_debug('in first if'||p_event);
    l_access_level := ASO_SECURITY_INT.Get_Quote_Access(p_resource_id,l_quote_number);

    IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB: Access Level'||l_access_level, 1, 'Y');
    END IF;
    --pp_debug('Access level:' || l_access_level);
      IF  ((l_access_level <> 'UPDATE') or (l_max_version_flag <> 'Y') or (l_price_request_id is not null)) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            if (l_max_version_flag <> 'Y') then
              FND_MESSAGE.Set_Name('QOT', 'QOT_QTE_NOT_HIGH_VERSION');
              FND_MSG_PUB.Add;
	    elsif  (l_price_request_id is not null)  then
               FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
               FND_MSG_PUB.Add;
           end if;
	    RAISE FND_API.G_EXC_ERROR;
         END IF;

    ELSIF l_pricing_status IS NULL OR
        l_pricing_status <> 'C' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_PRICING_INCOMPLETE');
	      FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
    ELSIF l_tax_status IS NULL OR
        l_tax_status <> 'C' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_TAX_INCOMPLETE');
	      FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


  l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(P_Quote_Header_Id); -- Assigning the header record

END IF; -- P_event in ('SUBMITTED', 'CANCELED', 'ACCEPTED')

IF p_event = 'SUBMITTED' THEN
   IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB:Status - '||p_event, 1, 'Y');
    END IF;
  open  C_qte_status_id('PRICE APPROVAL PENDING');
  fetch C_qte_status_id into ln_quote_Status_id;
  close C_qte_status_id;
  --pp_debug('In Event Submitted'||ln_quote_Status_id);
  -- Checking for the quote status transition
  ASO_VALIDATE_PVT.Validate_Status_Transition(
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_source_status_id     => l_quote_Status_id,
                         p_dest_status_id       => ln_quote_Status_id,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data);


   --pp_debug('After status validation In Event Submitted'||ln_quote_Status_id);

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      --pp_debug('After status validation failure');
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_NO_QTE_STAT_TRANSITION');
        FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

  end if;

  update aso_quote_headers_All
  set last_update_date=l_last_update_date,quote_status_id=ln_quote_Status_id
  where quote_header_id=p_quote_header_id;


ELSIF p_event = 'ACCEPTED' THEN
  l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

  IF l_db_link is NOT NULL THEN
	  l_db_link := '@' || l_db_link;
  END IF;


  --pp_debug('accepted');
  open C_qte_status_id('PRICE APPROVAL PENDING');
  fetch C_qte_status_id into ld_quote_Status_id;
  close C_qte_status_id;

if l_quote_Status_id<> ld_quote_Status_id then
   SELECT count(*) into ln_count FROM
   ASO_STATUS_TRANSITIONS_V
   WHERE TO_STATUS_ID = ld_quote_Status_id
   AND FROM_STATUS_ID = l_quote_Status_id;

   if ln_count=0 then

       IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB:Status ln_count=0', 1, 'Y');
      END IF;

      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_NO_QTE_STAT_TRANSITION');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
      end if;
   else -- if valid transition to price approval pending
      IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB:Status ln_count>0'||ld_quote_Status_id, 1, 'Y');
      END IF;
    update aso_quote_headers_All
    set quote_status_id=ld_quote_Status_id
    where quote_header_id=p_quote_header_id;
   end if;  -- status transition doesnot exist
end if; -- if status is not price approval pending

  open C_qte_status_id('PRICING APPROVED');
  fetch C_qte_status_id into ln_quote_Status_id;
  close C_qte_status_id;

    IF aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('ASO_DEAL_PUB:Status ln_count>0'||ld_quote_Status_id||'new stat'||ln_quote_Status_id, 1, 'Y');
      END IF;

    ASO_VALIDATE_PVT.Validate_Status_Transition(
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_source_status_id     => ld_quote_Status_id,
                         p_dest_status_id       => ln_quote_Status_id,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data);

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      --pp_debug('After status validation failure');
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_NO_QTE_STAT_TRANSITION');
        FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   end if;

  l_qte_header_rec.quote_status_id:=ln_quote_Status_id;
  l_qte_header_rec.last_update_date := l_last_update_date;



-- for pricing adjustment updations
IF aso_debug_pub.g_debug_flag='Y' THEN
   aso_debug_pub.add(  'In call update quote from deal API Before Price Adjustment' , 1 ,'Y') ;
end if;
/*
l_modifier_line_profile:=fnd_profile.value('QPR_DEAL_DIFF_MODIFIER');
L_modifier_line_id:=to_number(l_modifier_line_profile);

 IF L_modifier_line_id is NULL THEN
	FND_MESSAGE.SET_NAME('ASO','ASO_DEAL_PRC_PROFILE_NOT_SET');
	--FND_MESSAGE.SET_TOKEN('PROFILE', 'QPR_DEAL_DIFF_MODIFIER');
	FND_MSG_PUB.ADD;
	IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'Profile is NULL ' , 1 ) ;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
END IF;


 IF  aso_debug_pub.g_debug_flag='Y' THEN
    aso_debug_pub.add(  'In call Update Quote From Deal API-Modifier ' || L_modifier_line_id , 1 ,'Y') ;
 END IF;
*/

-- using ref cursor for dynamic execution of multirow query

 OPEN prcadj_cv FOR 'SELECT  UOM_CODE ,CURRENCY_CODE ,ORDERED_QTY ,PRICE,  SOURCE_REF_LINE_ID, SHIP_METHOD_CODE ,PAYMENT_TERM_ID' ||
                   ' FROM QPR_INT_DEAL_V' || l_db_link ||
		  ' WHERE  CHANGED = ' || '''Y''' ||
		  ' AND SOURCE_REF_HEADER_ID =  :p_quote_header_id ' ||
		  ' AND SOURCE_REF_LINE_ID is not null AND SOURCE = 697'
		  USING p_quote_header_id ;

loop

  fetch prcadj_cv into l_uom_code ,l_currency_code ,l_ordered_qty,l_updated_line_price,l_quote_line_id,l_shipment_method_code,l_payment_term_id;
  --pp_debug('values from deal qty ' || l_ordered_qty||'price'||l_updated_line_price||'quote_line_id'||l_quote_line_id);
  exit when prcadj_cv%NOTFOUND;
  l_continue:='Y';
   IF  aso_debug_pub.g_debug_flag='Y' THEN
    aso_debug_pub.add(  'In call Update Quote From Deal API-source line id  ' || l_quote_line_id||'Price'||l_updated_line_price , 1 ) ;
   END IF;


    i:=i+1;
   -- Entering line level detail

    l_Qte_Line_Tbl(i) :=  ASO_UTILITY_PVT.Get_Qte_Line_rec;
    l_qte_line_tbl(i).QUOTE_HEADER_ID  := p_quote_header_id;
    l_qte_line_tbl(i).QUOTE_line_id  := l_quote_line_id;
    l_qte_line_tbl(i).operation_code  := 'UPDATE';




-- fetching line level details
   open c_quote_line(l_quote_line_id);
   fetch c_quote_line into l_line_quote_price,l_line_qty,l_line_ship_method_code,l_line_payment_term_id,l_pricing_line_type_indicator;
   close c_quote_line;

    if  l_pricing_line_type_indicator<> 'F' then
       l_qte_line_tbl(i).PRICING_LINE_TYPE_INDICATOR:='D';
    end if;

-- checking for quanity
if (l_ordered_qty is not null) and (l_ordered_qty<>l_line_qty) then
    IF  aso_debug_pub.g_debug_flag='Y' THEN
    aso_debug_pub.add(  'In call Update Quote From Deal API-qty change ' || l_ordered_qty , 1 ) ;
    --pp_debug('In call Update Quote From Deal API-qty change ' || l_ordered_qty);
   END IF;
    l_qte_line_tbl(i).quantity  :=l_ordered_qty;
    l_qte_line_tbl(i).pricing_quantity  :=l_ordered_qty;
end if;


-- for shipment line level changes
   if (l_shipment_method_code is not null) and (l_shipment_method_code<>l_line_ship_method_code)  then
     l_ln_shipment_Tbl1:= ASO_UTILITY_PVT.Query_Shipment_Rows(P_Quote_Header_Id,l_quote_line_id); -- For Fetching line shipment terms

     IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'In call update quote from deal API Before Shipment'|| l_ln_shipment_Tbl1.count , 1 ) ;
     END IF;
     s_index:=s_index+1;
     if l_ln_shipment_Tbl1.count = 0 then
        l_ln_shipment_Tbl(s_index):=ASO_QUOTE_PUB.G_MISS_Shipment_REC;
        l_ln_shipment_Tbl(s_index).Quote_Header_Id :=  P_Quote_Header_Id;
	l_ln_shipment_Tbl(s_index).Quote_line_Id :=  l_quote_line_id;
	l_ln_shipment_Tbl(s_index).SHIP_METHOD_CODE :=  l_shipment_method_code;
        l_ln_shipment_Tbl(s_index).operation_code := 'CREATE' ;
     elsif l_ln_shipment_Tbl1.count > 0 then
        l_ln_shipment_Tbl(s_index):=ASO_QUOTE_PUB.G_MISS_Shipment_REC;
	l_ln_shipment_rec:=l_ln_shipment_Tbl1(1);
        l_ln_shipment_rec.Quote_Header_Id :=  P_Quote_Header_Id;
	l_ln_shipment_rec.Quote_line_Id :=  l_quote_line_id;
	l_ln_shipment_rec.SHIP_METHOD_CODE :=  l_shipment_method_code;
        l_ln_shipment_rec.operation_code := 'UPDATE' ;
	l_ln_shipment_Tbl(s_index):=l_ln_shipment_rec;
        --pp_debug('Entered shipment shipment id'||  l_ln_shipment_rec.shipment_id);
     end if;

   end if;
-- end shipment

IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'In call update quote from deal API after payment number of rows: '||l_ln_shipment_Tbl.count, 1 ) ;
     END IF;


  --pp_debug('before Entered payment'||  l_payment_term_id||'line'||l_line_payment_term_id);
  -- for payment terms line level changes
  IF (l_payment_term_id is not NULL) and (l_payment_term_id <> l_line_payment_term_id) THEN
     l_ln_Payment_Tbl1:= ASO_UTILITY_PVT.Query_Payment_Rows(P_Quote_Header_Id,l_quote_line_id); -- For Fetching header payment terms
     IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'In call update quote from deal API payment number of rows: '||l_ln_Payment_Tbl1.count||',payment term id'||l_payment_term_id , 1 ) ;
     END IF;
     pa_index:=pa_index+1;
     if l_ln_Payment_Tbl1.count = 0 then
        l_ln_Payment_Tbl(pa_index):=ASO_QUOTE_PUB.G_MISS_Payment_REC;
        l_ln_Payment_Tbl(pa_index).Quote_Header_Id :=  P_Quote_Header_Id;
	l_ln_Payment_Tbl(pa_index).Quote_line_Id :=  l_quote_line_id;
	l_ln_Payment_Tbl(pa_index).PAYMENT_TERM_ID :=  l_payment_term_id;
        l_ln_Payment_Tbl(pa_index).operation_code := 'CREATE' ;
     elsif l_ln_Payment_Tbl1.count > 0 then
        l_ln_Payment_Tbl(pa_index):=ASO_QUOTE_PUB.G_MISS_Payment_REC;
	l_ln_Payment_rec:=l_ln_Payment_Tbl1(1);
	IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'In call update quote from deal API after payment number of rows: '||l_ln_Payment_rec.payment_id, 1 ) ;
        END IF;
        l_ln_Payment_rec.PAYMENT_TERM_ID :=  l_payment_term_id;
	l_ln_Payment_rec.Quote_Header_Id :=  P_Quote_Header_Id;
	l_ln_Payment_rec.Quote_line_Id :=  l_quote_line_id;
	l_ln_Payment_rec.operation_code := 'UPDATE' ;
	l_ln_Payment_Tbl(pa_index):=l_ln_Payment_rec;
     end if;

  END IF;
-- end payment
IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'In call update quote from deal API after payment number of rows: '||l_ln_Payment_Tbl.count, 1 ) ;
END IF;

-- New Coding for already applied line level adjustments

-- Getting the modifier profile value
 l_modifier_line_profile:=fnd_profile.value('QPR_DEAL_DIFF_MODIFIER');
 L_modifier_line_id:=to_number(l_modifier_line_profile);


for cur_auto_adj in cur_app_adj(p_quote_header_id,l_quote_line_id,l_modifier_line_id)
loop

  IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'Entered new code for previous adjustments cur_auto_adj', 1 ) ;
  END IF;

   p_index:=p_index+1;
   -- Assigning the price adjustments for line id fetched
   l_Price_Adjustment_Tbl(p_index):= ASO_UTILITY_PVT.Get_price_adj_Rec;
   l_Price_Adjustment_Tbl(p_index).quote_header_id:=p_quote_header_id;
   l_Price_Adjustment_Tbl(p_index).quote_line_id:=l_quote_line_id;
   l_Price_Adjustment_Tbl(p_index).price_adjustment_id:= cur_auto_adj.price_adjustment_id;
   l_Price_Adjustment_Tbl(p_index).PRICE_BREAK_TYPE_CODE:= cur_auto_adj.PRICE_BREAK_TYPE_CODE;

   l_Price_Adjustment_Tbl(p_index).MODIFIER_HEADER_ID:= cur_auto_adj.MODIFIER_HEADER_ID;
   l_Price_Adjustment_Tbl(p_index).MODIFIER_LINE_ID:= cur_auto_adj.MODIFIER_LINE_ID;
   l_Price_Adjustment_Tbl(p_index).MODIFIER_LINE_TYPE_CODE:= cur_auto_adj.MODIFIER_LINE_TYPE_CODE;
   l_Price_Adjustment_Tbl(p_index).PRICING_GROUP_SEQUENCE:= cur_auto_adj.PRICING_GROUP_SEQUENCE;

   l_Price_Adjustment_Tbl(p_index).PRICING_PHASE_ID:= cur_auto_adj.PRICING_PHASE_ID;
   l_Price_Adjustment_Tbl(p_index).MODIFIED_FROM:= cur_auto_adj.MODIFIED_FROM;
   l_Price_Adjustment_Tbl(p_index).MODIFIED_TO:= cur_auto_adj.MODIFIED_TO;
   l_Price_Adjustment_Tbl(p_index).UPDATE_ALLOWABLE_FLAG:= cur_auto_adj.UPDATE_ALLOWABLE_FLAG;

   l_Price_Adjustment_Tbl(p_index).ON_INVOICE_FLAG:= cur_auto_adj.ON_INVOICE_FLAG;
   l_Price_Adjustment_Tbl(p_index).MODIFIER_LEVEL_CODE:= cur_auto_adj.MODIFIER_LEVEL_CODE;
   l_Price_Adjustment_Tbl(p_index).BENEFIT_QTY:= cur_auto_adj.BENEFIT_QTY;
   l_Price_Adjustment_Tbl(p_index).BENEFIT_UOM_CODE:= cur_auto_adj.BENEFIT_UOM_CODE;

   l_Price_Adjustment_Tbl(p_index).LIST_LINE_NO:= cur_auto_adj.LIST_LINE_NO;
   l_Price_Adjustment_Tbl(p_index).ACCRUAL_FLAG:= cur_auto_adj.ACCRUAL_FLAG;
   l_Price_Adjustment_Tbl(p_index).ACCRUAL_CONVERSION_RATE:= cur_auto_adj.ACCRUAL_CONVERSION_RATE;
   l_Price_Adjustment_Tbl(p_index).CHARGE_TYPE_CODE:= cur_auto_adj.CHARGE_TYPE_CODE;

   l_Price_Adjustment_Tbl(p_index).CHARGE_SUBTYPE_CODE:= cur_auto_adj.CHARGE_SUBTYPE_CODE;
   l_Price_Adjustment_Tbl(p_index).RANGE_BREAK_QUANTITY:= cur_auto_adj.RANGE_BREAK_QUANTITY;
   l_Price_Adjustment_Tbl(p_index).MODIFIER_MECHANISM_TYPE_CODE:= cur_auto_adj.MODIFIER_MECHANISM_TYPE_CODE;
   l_Price_Adjustment_Tbl(p_index).automatic_flag:= cur_auto_adj.automatic_flag;


   l_Price_Adjustment_Tbl(p_index).applied_flag:= 'Y';
   l_Price_Adjustment_Tbl(p_index).updated_flag:= 'Y';
   l_Price_Adjustment_Tbl(p_index).Operand :=  cur_auto_adj.operand;
   l_Price_Adjustment_Tbl(p_index).adjusted_amount:=nvl(cur_auto_adj.adjusted_amount,cur_auto_adj.operand);
   l_Price_Adjustment_Tbl(p_index).Arithmetic_operator := cur_auto_adj.ARITHMETIC_OPERATOR;
   l_Price_Adjustment_Tbl(p_index).operation_code := 'UPDATE';
   l_Price_Adjustment_Tbl(p_index).change_reason_code :=cur_auto_adj.change_reason_code;
   l_Price_Adjustment_Tbl(p_index).change_reason_text:=cur_auto_adj.change_reason_text;
end loop;

  IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'count new code for previous adjustments'||l_Price_Adjustment_Tbl.count, 1 ) ;
  END IF;


-- end coding for already applied automatic adjustments

if  (l_updated_line_price is not null) and  (l_line_quote_price<>l_updated_line_price) then -- checking if price has been modified or not


/* l_modifier_line_profile:=fnd_profile.value('QPR_DEAL_DIFF_MODIFIER');
 L_modifier_line_id:=to_number(l_modifier_line_profile);
*/
 IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'Line Modifier Value'||L_modifier_line_id, 1 ) ;
 END IF;

 IF L_modifier_line_id is NULL THEN
	FND_MESSAGE.SET_NAME('ASO','ASO_DEAL_PRC_PROFILE_NOT_SET');
	--FND_MESSAGE.SET_TOKEN('PROFILE', 'QPR_DEAL_DIFF_MODIFIER');
	FND_MSG_PUB.ADD;
	IF aso_debug_pub.g_debug_flag='Y' THEN
	    aso_debug_pub.add(  'Profile is NULL ' , 1 ) ;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
 END IF;


 IF  aso_debug_pub.g_debug_flag='Y' THEN
    aso_debug_pub.add(  'In call Update Quote From Deal API-Modifier ' || L_modifier_line_id , 1 ,'Y') ;
 END IF;



  --pp_debug('in approved event price'||l_quote_line_id);
  select count(*) into l_count_modifier
  FROM aso_price_adjustments apa, Aso_quote_lines_all aqla
    WHERE apa.quote_line_id =  l_quote_line_id
      AND apa.modifier_line_id = l_modifier_line_id
      AND nvl(apa.expiration_date,sysdate) >= sysdate
      AND apa.quote_line_id = aqla.quote_line_id;

  if l_count_modifier = 1 then
    l_continue:='Y';
    SELECT apa.price_adjustment_id, apa.Applied_flag, apa.Operand, aqla.line_quote_price
    into l_price_adjustment_id,l_applied_flag,l_operand,l_line_quote_price
    FROM aso_price_adjustments apa, Aso_quote_lines_all aqla
    WHERE apa.quote_line_id =  l_quote_line_id
      AND apa.modifier_line_id = l_modifier_line_id
      AND nvl(apa.expiration_date,sysdate) >= sysdate
      AND apa.quote_line_id = aqla.quote_line_id;
  elsif l_count_modifier=0 then
      l_continue:='N';
      IF  aso_debug_pub.g_debug_flag='Y' THEN
      aso_debug_pub.add(  'Modifier NO data found-Dont update this Line for modifier'  , 1,'Y' ) ; -- need to have an error message here
      end if;

      select name into l_modifier_name
      from qp_list_headers_tl t,qp_list_lines td
      where t.list_header_id = td.list_header_id
      and list_line_id=l_modifier_line_id
      AND t.LANGUAGE(+) = userenv('LANG');

      FND_MESSAGE.SET_NAME('ASO','ASO_DEAL_PRC_ADJ_NOT_DEFINED');
      FND_MESSAGE.SET_TOKEN('COLUMN', l_modifier_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;


   IF  aso_debug_pub.g_debug_flag='Y' THEN
      aso_debug_pub.add(  'Modifier Adjustment exist'||l_continue  , 1,'Y' ) ;
      --pp_debug( 'Modifier Adjustment exist'||l_continue);
   end if;

   IF (l_continue='Y')  then  -- Adjustment exists for the line

     IF l_applied_flag = 'Y' then  -- Calculating Operand
      ld_operand:= (l_line_quote_price+l_operand) - l_updated_line_price;
     Elsif  l_applied_flag = 'N' then
      --pp_debug( 'Modifier Adjustment exist ld_operand121'||ld_operand);
      ld_operand:= l_line_quote_price - l_updated_line_price ;
     End if;

     IF  aso_debug_pub.g_debug_flag='Y' THEN
      aso_debug_pub.add(  'Modifier Calculated operand'||ld_operand  , 1,'Y' ) ;
    end if;
     --pp_debug( 'Modifier Adjustment exist ld_operand'||ld_operand);

   p_index:=p_index+1;
   -- Assigning the price adjustments for line id fetched
   l_Price_Adjustment_Tbl(p_index):= ASO_UTILITY_PVT.Get_price_adj_Rec;
   l_Price_Adjustment_Tbl(p_index).quote_header_id:=p_quote_header_id;
   l_Price_Adjustment_Tbl(p_index).quote_line_id:=l_quote_line_id;
   l_Price_Adjustment_Tbl(p_index).price_adjustment_id:= l_price_adjustment_id;
   l_Price_Adjustment_Tbl(p_index).applied_flag:= 'Y';
   l_Price_Adjustment_Tbl(p_index).updated_flag:= 'Y';
   l_Price_Adjustment_Tbl(p_index).Operand :=  ld_operand;
   l_Price_Adjustment_Tbl(p_index).adjusted_amount:=ld_operand;
   l_Price_Adjustment_Tbl(p_index).Arithmetic_operator := 'AMT';
   l_Price_Adjustment_Tbl(p_index).operation_code := 'UPDATE';
   l_Price_Adjustment_Tbl(p_index).change_reason_code :='DEALS';
   l_Price_Adjustment_Tbl(p_index).change_reason_text:='Recommendation from Deal Management';



 end if; -- l_continue = 'Y' end

end if;  -- price adjustment end

 end loop;
 close prcadj_cv;



  l_control_rec.auto_version_flag := 'N';
  l_control_rec.header_pricing_event := 'BATCH';
  l_control_rec.calculate_tax_flag := 'Y';
  l_control_rec.calculate_freight_charge_flag := 'Y';
  l_control_rec.price_mode := 'ENTIRE_QUOTE';
  l_control_rec.pricing_request_type:='ASO';




IF  aso_debug_pub.g_debug_flag='Y' THEN
      aso_debug_pub.add(  'Modifier Price adjustment'||l_Price_Adjustment_Tbl.count  , 1,'Y' ) ;
    end if;
--pp_debug('end approved event price'||l_Price_Adjustment_Tbl.count);
--pp_debug('end approved event price'||l_Qte_Line_Tbl.count);

ELSIF p_event = 'CANCELED' THEN
	    -- Set quote status to 'PRICE APPROVAL CANCELED'
    open C_qte_status_id('PRICE APPROVAL CANCELED');
    fetch C_qte_status_id into ln_quote_Status_id;
    close C_qte_status_id;

    -- Checking for the quote status transition
   ASO_VALIDATE_PVT.Validate_Status_Transition(
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_source_status_id     => l_quote_Status_id,
                         p_dest_status_id       => ln_quote_Status_id,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data);

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_NO_QTE_STAT_TRANSITION');
        FND_MSG_PUB.ADD;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
  end if;

  update aso_quote_headers_All
  set last_update_date=l_last_update_date,quote_status_id=ln_quote_Status_id
  where quote_header_id=p_quote_header_id;

END IF;

IF P_event in ('ACCEPTED') then
   IF aso_debug_pub.g_debug_flag = 'Y' then
     aso_debug_pub.add('ASO_DEAL_PUB before aso_quote_pub.update_quote - '||p_event, 1, 'Y');
     aso_debug_pub.add('ASO_DEAL_PUB:l_qte_header_rec.quote_status_id - '||l_qte_header_rec.quote_status_id, 1, 'Y');
     aso_debug_pub.ADD ('Before calling update quote: Setting the single org context to org_id:  '|| l_qte_header_rec.org_id,1,'N');
    END IF;

     -- Setting MOAC
    mo_global.set_policy_context('S', l_qte_header_rec.org_id);

    aso_quote_pub.update_quote (
      p_api_version_number         => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_control_rec                => l_control_rec,
      p_qte_header_rec             => l_qte_header_rec,
      p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      p_qte_line_tbl               => l_qte_line_tbl, -- need to change here
      p_qte_line_dtl_tbl           => aso_quote_pub.g_miss_qte_line_dtl_tbl,
      p_line_attr_ext_tbl          => aso_quote_pub.g_miss_line_attribs_ext_tbl,
      p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
      p_price_adjustment_tbl       => l_Price_Adjustment_Tbl,
      p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
      p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
      p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_ln_payment_tbl             => l_ln_Payment_Tbl,
      p_ln_shipment_tbl            => l_ln_shipment_Tbl,
      p_ln_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_ln_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      x_qte_header_rec             => lx_qte_header_rec,
      x_qte_line_tbl               => lx_qte_line_tbl,
      x_qte_line_dtl_tbl           => lx_qte_line_dtl_tbl,
      x_hd_price_attributes_tbl    => lx_hd_price_attr_tbl,
      x_hd_payment_tbl             => lx_hd_payment_tbl,
      x_hd_shipment_tbl            => lx_hd_shipment_tbl,
      x_hd_freight_charge_tbl      => lx_hd_freight_charge_tbl,
      x_hd_tax_detail_tbl          => lx_hd_tax_detail_tbl,
      x_line_attr_ext_tbl          => lx_line_attr_ext_tbl,
      x_line_rltship_tbl           => lx_line_rltship_tbl,
      x_price_adjustment_tbl       => lx_price_adjustment_tbl,
      x_price_adj_attr_tbl         => lx_price_adj_attr_tbl,
      x_price_adj_rltship_tbl      => lx_price_adj_rltship_tbl,
      x_ln_price_attributes_tbl    => lx_ln_price_attr_tbl,
      x_ln_payment_tbl             => lx_ln_payment_tbl,
      x_ln_shipment_tbl            => lx_ln_shipment_tbl,
      x_ln_freight_charge_tbl      => lx_ln_freight_charge_tbl,
      x_ln_tax_detail_tbl          => lx_ln_tax_detail_tbl,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

   --pp_debug('after calling aso_quote_pub');
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB:  after Update_Quote', 1, 'Y');
    END IF;

    if x_return_status = FND_API.G_RET_STS_SUCCESS then
      Update aso_quote_lines_all
      set PRICING_LINE_TYPE_INDICATOR=NULL
      where quote_header_id = p_quote_header_id
      and PRICING_LINE_TYPE_INDICATOR='D';


    elsIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         --pp_debug('after calling aso_quote_pub error');
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         --pp_debug('after calling aso_quote_pub unerror');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END IF; -- end if status


-- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
             --pp_debug('error  aso_quote_pub');


            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Exception in package : '|| G_PKG_NAME, 1, 'N');
		aso_debug_pub.add('Exception in API : '|| L_API_NAME, 1, 'N');
            end if;

            x_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


	    ASO_UTILITY_PVT.Get_Messages(x_msg_count, x_msg_data);



       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --pp_debug('unerror  aso_quote_pub'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

	  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Exception in package : '|| G_PKG_NAME, 1, 'N');
		aso_debug_pub.add('Exception in API : '|| L_API_NAME, 1, 'N');
            end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
          ASO_UTILITY_PVT.Get_Messages(x_msg_count, x_msg_data);

       WHEN OTHERS THEN
         --pp_debug('error  others aso_quote_pub'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Exception in package : '|| G_PKG_NAME, 1, 'N');
		aso_debug_pub.add('Exception in API : '|| L_API_NAME, 1, 'N');
		aso_debug_pub.add('SQLCODE : '|| SQLCODE, 1, 'N');
		aso_debug_pub.add('SQLERRM : '|| SQLERRM, 1, 'N');
	END IF;

        FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , g_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , l_api_name);
        FND_MSG_PUB.ADD;

        l_len_sqlerrm := Length(SQLERRM) ;
           While l_len_sqlerrm >= l_err Loop
             FND_MESSAGE.Set_Name('ASO', 'ASO_SQLERRM');
	     FND_MESSAGE.Set_token('ERR_TEXT' , substr(SQLERRM,l_err,240));
             l_err := l_err + 240;
             FND_MSG_PUB.ADD;
          end loop;

	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


	  FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
           ASO_UTILITY_PVT.Get_Messages(x_msg_count, x_msg_data);


END Update_Quote_From_Deal;



FUNCTION Get_Deal_Access
(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_HEADER_ID            IN   NUMBER
) RETURN VARCHAR2
IS

    l_access_level       VARCHAR2(10):='NONE';
    l_max_version_flag   VARCHAR2(1):=null;
    l_price_request_id 	 NUMBER := null;
    l_pricing_status   	 VARCHAR2(1) := null;
    l_quote_number       NUMBER;
    l_quote_status_id    NUMBER;
    t_quote_status_id    NUMBER;
    t_update_allowed_flag VARCHAR2(1) :='N';
    l_status_override VARCHAR2(1) := 'Y';

BEGIN

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: ****** Start of Get_Deal_Access API ******', 1, 'Y');
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Access: P_RESOURCE_ID:  ' || P_RESOURCE_ID, 1, 'Y');
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Access: P_QUOTE_HEADER_ID: ' || P_QUOTE_HEADER_ID, 1, 'Y');
    END IF;

    -- Getting quote header Details
    SELECT nvl(max_version_flag,'N'), price_request_id, nvl(pricing_status_indicator,'C'),quote_number,quote_status_id
     into  l_max_version_flag, l_price_request_id,l_pricing_status,l_quote_number,l_quote_status_id
	     FROM aso_quote_headers_all
	     WHERE quote_header_id = p_quote_header_id;

    -- Getting the user level access
    l_access_level:=ASO_SECURITY_INT.Get_Quote_Access (p_resource_id,l_quote_number);

     aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Access: Access level returned by ASO_SECURITY_INT: ' || l_access_level, 1, 'Y');

     -- User has update access to quote. In case user has access level 'READ' or 'NONE' for the quote nothing needs to be done
    -- check additional conditions for max version, batch pricing, status
    IF   l_access_level = 'UPDATE' then

       SELECT quote_status_id INTO t_quote_status_id
	     FROM aso_quote_statuses_b
	     WHERE status_code = 'PRICE APPROVAL PENDING';


	     if l_max_version_flag='N' then  -- checking for max version
	        l_access_level:='READ';
	    elsif   (t_quote_status_id<>l_quote_status_id)  then

	          SELECT update_allowed_flag
                   INTO t_update_allowed_flag
    		    FROM aso_quote_statuses_b
	       	   WHERE quote_status_id = l_quote_status_id;

		    l_status_override :=nvl(fnd_profile.value('ASO_STATUS_OVERRIDE'),'N');

	            If (t_update_allowed_flag='N' and l_status_override = 'N') then
	              l_access_level:='READ';
		    end if;

             elsif  l_price_request_id is not null then -- checking for batch pricing
               l_access_level:= 'READ';
       end if;
    END IF;
    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Access: End of API body', 1, 'Y');
    END IF;
    RETURN l_access_level;

END Get_Deal_Access;


FUNCTION Get_Deal_Enable_Buttons
(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_HEADER_ID            IN   NUMBER
) RETURN VARCHAR2
IS

    l_access_level       VARCHAR2(10):='NONE';
    l_max_version_flag   VARCHAR2(1):=null;
    l_price_request_id 	 NUMBER := null;
    l_pricing_status   	 VARCHAR2(1) := null;
    l_quote_number       NUMBER;

BEGIN

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: ****** Start of Get_Deal_Enable_Buttons API ******', 1, 'Y');
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Enable_Buttons: P_RESOURCE_ID:  ' || P_RESOURCE_ID, 1, 'Y');
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Enable_Buttons: P_QUOTE_HEADER_ID: ' || P_QUOTE_HEADER_ID, 1, 'Y');
    END IF;

    -- Getting quote header Details
    SELECT nvl(max_version_flag,'N'), price_request_id, nvl(pricing_status_indicator,'C'),quote_number
     into  l_max_version_flag, l_price_request_id,l_pricing_status,l_quote_number
	     FROM aso_quote_headers_all
	     WHERE quote_header_id = p_quote_header_id;

    -- Getting the user level access
    l_access_level:=ASO_SECURITY_INT.Get_Quote_Access (p_resource_id,l_quote_number);

     aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Enable_Buttons: Access level returned by ASO_SECURITY_INT: ' || l_access_level, 1, 'Y');

     -- User has update access to quote. In case user has access level 'READ' or 'NONE' for the quote nothing needs to be done
    -- check additional conditions for max version, batch pricing, status
    IF   l_access_level = 'UPDATE' then


	     if l_max_version_flag='N' then  -- checking for max version
	        l_access_level:='READ';

             elsif  l_price_request_id is not null then -- checking for batch pricing
               l_access_level:= 'READ';
       end if;
    END IF;

    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Enable_Buttons: l_access_level: ' || l_access_level, 1, 'Y');

     -- End of API body
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_DEAL_PUB: Get_Deal_Enable_Buttons: End of API body', 1, 'Y');
    END IF;


   if l_access_level = 'UPDATE' then
    return 'Y';
   else
     return 'N';
   end if;



END Get_Deal_Enable_Buttons;

End ASO_DEAL_PUB;

/
