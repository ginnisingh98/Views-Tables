--------------------------------------------------------
--  DDL for Package Body ASO_VALIDATE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_VALIDATE_PRICING_PVT" as
/* $Header: asovvprb.pls 120.3 2005/10/26 04:17:59 gsachdev ship $ */
-- Start of Comments
-- Package name     : ASO_VALIDATE_PRICING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_VALIDATE_PRICING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovvprb.pls';


/*local functions and procedures*/

PROCEDURE Copy_Attribs_To_Req(
    p_line_index                            number,
    p_pricing_contexts_Tbl                  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl                QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    l_attr_index    number := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index    number := nvl(px_Req_qual_tbl.last,0);
BEGIN
    for i in 1..p_pricing_contexts_Tbl.count loop
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
    end loop;
    -- Copy the qualifiers
    for i in 1..p_qualifier_contexts_Tbl.count loop
        l_qual_index := l_qual_index +1;
        px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'N';
        px_Req_qual_tbl(l_qual_index).line_index := p_line_index;
        px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
                                        p_qualifier_contexts_Tbl(i).context_name;
        px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
                                      p_qualifier_contexts_Tbl(i).Attribute_Name;
        px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
                                     p_qualifier_contexts_Tbl(i).attribute_value;
    end loop;
end copy_attribs_to_Req;

PROCEDURE Copy_hdr_attr_to_line(
    p_line_index                           number,
    p_pricing_contexts_Tbl                 QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl               QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */          QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */          QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    l_attr_index              number := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index              number := nvl(px_Req_qual_tbl.last,0);
    copy_hdr_rec_to_line_flag boolean := TRUE;
BEGIN
    for i in 1..p_pricing_contexts_Tbl.count loop
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
    end loop;
    -- Copy the qualifiers
    for i in 1..p_qualifier_contexts_Tbl.count loop
        copy_hdr_rec_to_line_flag := TRUE;
        for j in 1..px_Req_qual_tbl.count loop
            if px_Req_qual_tbl(j).QUALIFIER_CONTEXT = p_qualifier_contexts_Tbl(i).context_name
               and px_Req_qual_tbl(j).QUALIFIER_ATTRIBUTE = p_qualifier_contexts_Tbl(i).Attribute_Name
               and p_line_index = px_Req_qual_tbl(j).line_index
            then
                copy_hdr_rec_to_line_flag := FALSE;
            end if;
        end loop;

        if copy_hdr_rec_to_line_flag then
           l_qual_index := l_qual_index +1;
           px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'N';
           px_Req_qual_tbl(l_qual_index).line_index := p_line_index;
           px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
                                        p_qualifier_contexts_Tbl(i).context_name;
           px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
                                        p_qualifier_contexts_Tbl(i).Attribute_Name;
           px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
                                        p_qualifier_contexts_Tbl(i).attribute_value;
        end if;
    end loop;
end Copy_hdr_attr_to_line;

procedure copy_Header_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_header_rec                        ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.LINE_TBL_TYPE)
IS
BEGIN
    px_req_line_tbl(1).REQUEST_TYPE_CODE := p_Request_Type;
    px_req_line_tbl(1).PRICING_EVENT := p_pricing_event;
    px_req_line_tbl(1).LINE_INDEX := 1;
    px_req_line_tbl(1).LINE_TYPE_CODE := 'ORDER';
    px_req_line_tbl(1).CURRENCY_CODE := p_Header_rec.currency_code;
    px_req_line_tbl(1).PRICE_FLAG := 'Y';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE '
				     ||ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE,1,'N');
    END IF;
    /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
    if ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE = FND_API.G_MISS_DATE
       OR ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE is NULL then
         px_req_line_tbl(1).PRICING_EFFECTIVE_DATE := trunc(sysdate);
    else
        px_req_line_tbl(1).PRICING_EFFECTIVE_DATE := trunc(ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE);
    end if;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Header Request copy: px_req_line_tbl(1).PRICING_EFFECTIVE_DATE '
                         ||px_req_line_tbl(1).PRICING_EFFECTIVE_DATE,1,'N');
    END IF;
end copy_Header_to_request;

procedure copy_Line_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_line_rec                          ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_line_dtl_rec                      ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_control_rec      IN               ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.LINE_TBL_TYPE)
is
    l_req_line_rec    QP_PREQ_GRP.LINE_REC_TYPE;
    l_uom_rate        NUMBER;
begin
 /*
  * New Code: Passing quote line id to QP pl/sql tbl
  */
    l_req_line_rec.line_id := p_Line_rec.quote_line_id;
    l_req_line_rec.REQUEST_TYPE_CODE := p_Request_Type;
    l_req_line_rec.PRICING_EVENT :=p_pricing_event;
    l_req_line_rec.LINE_INDEX := px_req_line_tbl.count+1;
    l_req_line_rec.LINE_TYPE_CODE := 'LINE';
    l_req_line_rec.LINE_QUANTITY := p_Line_rec.quantity;
    l_req_line_rec.LINE_UOM_CODE := p_Line_rec.uom_code;
    l_req_line_rec.CURRENCY_CODE := p_Line_rec.currency_code;
    If p_Line_rec.line_list_price <> FND_API.G_MISS_NUM Then
       l_req_line_rec.UNIT_PRICE := p_Line_rec.line_list_price;
    Else
       l_req_line_rec.UNIT_PRICE := Null;
    End If;
    -- Added for Service Item after pathcset E
    If p_line_dtl_rec.service_period is not null
       AND p_line_dtl_rec.service_period <> fnd_api.g_miss_char then
       If (p_line_dtl_rec.service_period = p_Line_rec.uom_code) Then
          l_req_line_rec.UOM_QUANTITY := p_line_dtl_rec.service_duration;
       Else
          INV_CONVERT.INV_UM_CONVERSION(
                   From_Unit  => p_line_dtl_rec.service_period
                   ,To_Unit   => p_Line_rec.uom_code
                   ,Item_ID   => p_Line_rec.Inventory_item_id
                   ,Uom_Rate  => l_Uom_rate);
         l_req_line_rec.UOM_QUANTITY := p_line_dtl_rec.service_duration * l_uom_rate;
      End If;
    End If;
    -- Change for manual discount updating UPDATED_ADJUSTED_UNIT_PRICE
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('In Copy line to req p_Line_rec.SELLING_PRICE_CHANGE  '
                         ||p_Line_rec.SELLING_PRICE_CHANGE,1,'Y');
    END IF;
    If p_Line_rec.SELLING_PRICE_CHANGE = 'Y' then
       l_req_line_rec.UPDATED_ADJUSTED_UNIT_PRICE := p_Line_rec.line_quote_price;
    End If;
    l_req_line_rec.PRICE_FLAG := 'Y';
    /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
    if ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE = FND_API.G_MISS_DATE
       OR ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE is NULL then
        l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(sysdate);
    else
        l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE);
    end if;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('copy line request: l_req_line_rec.PRICING_EFFECTIVE_DATE '
                         ||l_req_line_rec.PRICING_EFFECTIVE_DATE,1,'N');
	 aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:copy line request: p_Line_rec.CHARGE_PERIODICITY_CODE '
	                          ||p_Line_rec.CHARGE_PERIODICITY_CODE,1,'N');
    END IF;
    l_req_line_rec.CHARGE_PERIODICITY_CODE := p_Line_rec.CHARGE_PERIODICITY_CODE;

    px_req_line_tbl(px_req_line_tbl.count+1) := l_req_line_rec;
end copy_Line_to_request;
/*End of local functions and Procedures*/



/*Main API*/

PROCEDURE Validate_Pricing_Order(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_hd_price_attr_tbl        IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     p_line_rltship_tbl         IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Tbl,
     p_qte_line_dtl_tbl         IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl,
     p_ln_shipment_tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl,
     p_ln_price_attr_tbl        IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
     x_qte_header_rec           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_qte_line_dtl_tbl         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
     x_price_adj_tbl            OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
     x_price_adj_attr_tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
     x_price_adj_rltship_tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Validate_Pricing_Order';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_request_type                VARCHAR2(60);
    l_pricing_event               VARCHAR2(30);
    l_control_rec                 QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_req_line_tbl                QP_PREQ_GRP.LINE_TBL_TYPE;
    l_Req_qual_tbl                QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_Req_line_attr_tbl           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_Req_LINE_DETAIL_tbl         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_LINE_DETAIL_qual_tbl    QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_LINE_DETAIL_attr_tbl    QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_lines_tbl       QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_req_adj_related_lines_tbl   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_hd_pricing_contexts_Tbl     QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_hd_qual_contexts_Tbl        QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_pricing_contexts_Tbl        QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_qual_contexts_Tbl           QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    lx_req_line_tbl               QP_PREQ_GRP.LINE_TBL_TYPE;
    lx_req_qual_tbl               QP_PREQ_GRP.QUAL_TBL_TYPE;
    lx_req_line_attr_tbl          QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    lx_req_LINE_DETAIL_tbl        QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    lx_req_LINE_DETAIL_qual_tbl   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    lx_req_LINE_DETAIL_attr_tbl   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    lx_req_related_lines_tbl      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_qte_line_id                 NUMBER;
    l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_return_status               VARCHAR2(1);
    l_return_status_text          VARCHAR2(2000);
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    k                             BINARY_INTEGER;
    l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_rec                ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_srv_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_qte_line_prcd_parent        ASO_PRICING_INT.Index_Link_Tbl_Type;
    l_qte_line_prcd_child         ASO_PRICING_INT.Index_Link_Tbl_Type;
    lx_req_line_rec               QP_PREQ_GRP.LINE_REC_TYPE;
    l_call_flg                    Varchar2(1):='Q';
    l_db_tbl_flg                  Varchar2(3);
    G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

  CURSOR C_status_code IS
         select line_id,
                pricing_status_code,
                pricing_status_text
         from  qp_preq_lines_tmp lines
         where lines.line_type_code='LINE'
         and  lines.pricing_status_code in(
                  QP_PREQ_GRP.g_status_invalid_price_list,
                  QP_PREQ_GRP.g_sts_lhs_not_found,
                  QP_PREQ_GRP.g_status_formula_error,
                  QP_PREQ_GRP.g_status_other_errors,
                  fnd_api.g_ret_sts_unexp_error,
                  fnd_api.g_ret_sts_error,
                  QP_PREQ_GRP.g_status_calc_error,
                  QP_PREQ_GRP.g_status_uom_failure,
                  QP_PREQ_GRP.g_status_invalid_uom,
                  QP_PREQ_GRP.g_status_dup_price_list,
                  QP_PREQ_GRP.g_status_invalid_uom_conv,
                  QP_PREQ_GRP.g_status_invalid_incomp,
                  QP_PREQ_GRP.g_status_best_price_eval_error);




BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: Validate_Pricing_Order Starts',1,'N');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT PRICING_ORDER_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin FND_API.to_Boolean'||p_init_msg_list, 1, 'Y');
       END IF;
       FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:p_control_rec.request_type:'
				     ||p_control_rec.request_type,1,'N');
      aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:p_control_rec.pricing_event:'
				     ||p_control_rec.pricing_event,1,'N');
    END IF;
    l_request_type := p_control_rec.request_type;
    l_pricing_event := p_control_rec.pricing_event;

    ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
          p_qte_header_rec     => p_qte_header_rec,
          p_shipment_rec       => p_hd_shipment_rec);

   /*Debug msgs to check the value of global header record elements passed into pricing order*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:QP_ATTR_MAPPING_PUB.Build_Contexts Starts',1,'Y');
   END IF;
   QP_ATTR_MAPPING_PUB.Build_Contexts (
        P_REQUEST_TYPE_CODE          => l_request_type,
        P_PRICING_TYPE               => 'H',
        X_PRICE_CONTEXTS_RESULT_TBL  => l_hd_pricing_contexts_tbl,
        X_QUAL_CONTEXTS_RESULT_TBL   => l_hd_qual_contexts_tbl);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:QP_ATTR_MAPPING_PUB.Build_Contexts Ends',1,'Y');
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Copy_Attribs_To_Req Starts',1,'Y');
   END IF;

   Copy_Attribs_To_Req (
    p_line_index             => 1,
    p_pricing_contexts_tbl   => l_hd_pricing_contexts_tbl,
    p_qualifier_contexts_tbl => l_hd_qual_contexts_tbl,
    px_req_line_attr_tbl     => l_req_line_attr_tbl,
    px_req_qual_tbl          => l_req_qual_tbl);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Copy_Attribs_To_Req Ends',1,'Y');
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Copy_Header_To_Request Starts',1,'Y');
   END IF;

   Copy_Header_To_Request(
       p_Request_Type        => l_request_type,
       p_pricing_event       => l_pricing_event,
       p_header_rec          => p_qte_header_rec,
       px_req_line_tbl       => l_Req_line_tbl);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Copy_Header_To_Request Ends',1,'Y');
     aso_debug_pub.add('p_qte_header_rec.quote_header_id:'||p_qte_header_rec.quote_header_id,1,'N');
   END IF;

   If p_qte_line_tbl.count = 0 then
      l_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows(p_qte_header_rec.quote_header_id);
   Else
      l_qte_line_tbl := p_qte_line_tbl;
   End If;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:l_qte_line_tbl.count'|| l_qte_line_tbl.count, 1, 'N');
   END IF;
   If l_qte_line_tbl.count > 0 Then
      FOR i IN 1..l_qte_line_tbl.count LOOP
          /*We store the line_index in quote_line_id before building the l_req_line_tbl */
          if l_qte_line_tbl(i).quote_line_id is null
             OR l_qte_line_tbl(i).quote_line_id = fnd_api.g_miss_num Then
                l_call_flg := 'O';
                l_qte_line_tbl(i).quote_line_id := i+1;
          end if;
          l_qte_line_id := l_qte_line_tbl(i).quote_line_id;
		/*Save a copy of the record to a different table before defaulting*/
          lx_qte_line_tbl(i) := l_qte_line_tbl(i);

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: l_qte_line_id:'||nvl(l_qte_line_id,0),1,'N');
          END IF;

          /* Default header_level currency_code and price list id to line level*/
          l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;

          If (l_qte_line_tbl(i).price_list_id is null
             OR l_qte_line_tbl(i).price_list_id= FND_API.G_MISS_NUM) Then
                l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
		End if;

          /*Query Detail Line tbl and shipment*/
		If l_call_flg = 'Q' then
             l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_id);
	        If l_qte_line_dtl_tbl.count >0 then
		      l_srv_line_dtl_tbl(l_srv_line_dtl_tbl.count+1):= l_qte_line_dtl_tbl(1);
             end if;

             l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
             IF l_qte_line_dtl_tbl.count = 1 THEN
                l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
             END IF;

             l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_rec.quote_header_id,
                                                                               l_qte_line_id);
             l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
             IF l_shipment_tbl.count = 1 THEN
                l_shipment_rec := l_shipment_tbl(1);
             END IF;
		End If;--If l_call_flg = 'Q' then

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin Setting up the G_LINE_REC', 1, 'Y');
          END IF;
          ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                     p_qte_line_rec               => l_qte_line_tbl(i),
                     p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                     p_shipment_rec               => l_shipment_rec);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End Setting up the G_LINE_REC', 1, 'Y');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin Setting up the Line Build_Contexts', 1, 'Y');
          END IF;
          QP_ATTR_MAPPING_PUB.Build_Contexts (
                     P_REQUEST_TYPE_CODE           => l_request_type,
                     P_PRICING_TYPE                => 'L',
                     X_PRICE_CONTEXTS_RESULT_TBL   => l_pricing_contexts_tbl,
                     X_QUAL_CONTEXTS_RESULT_TBL    => l_qual_contexts_tbl);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End Setting up the Line Build_Contexts', 1, 'Y');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin Setting up the Copy_Attribs_To_Req', 1, 'Y');
          END IF;
          Copy_Attribs_To_Req (
                     p_line_index                  => i+1,
                     p_pricing_contexts_tbl        => l_pricing_contexts_tbl,
                     p_qualifier_contexts_tbl      => l_qual_contexts_tbl,
                     px_req_line_attr_tbl          => l_req_line_attr_tbl,
                     px_req_qual_tbl               => l_req_qual_tbl);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End Setting up the Copy_Attribs_To_Req', 1, 'Y');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin Setting up the Copy_hdr_attr_to_line', 1, 'Y');
          END IF;
          Copy_hdr_attr_to_line (
                     p_line_index                  => i+1,
                     p_pricing_contexts_tbl        => l_hd_pricing_contexts_tbl,
                     p_qualifier_contexts_tbl      => l_hd_qual_contexts_tbl,
                     px_req_line_attr_tbl          => l_req_line_attr_tbl,
                     px_req_qual_tbl               => l_req_qual_tbl);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End Setting up the Copy_hdr_attr_to_line', 1, 'Y');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Begin Setting up the Copy_Line_To_Request', 1, 'Y');
          END IF;
          Copy_Line_To_Request(
                     p_Request_Type                => l_request_type,
                     p_pricing_event               => l_pricing_event,
                     p_line_rec                    => l_qte_line_tbl(i),
                     p_line_dtl_rec                => l_qte_line_dtl_rec,
                     p_control_rec                 => p_control_rec,
                     px_req_line_tbl               => l_Req_line_tbl);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End Setting up the Copy_Line_To_Request', 1, 'Y');
          END IF;

          /*Keeping track of indexes for service processing*/
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:serviceable_product_flag:'
                         ||l_qte_line_tbl(i).serviceable_product_flag,1,'Y');
          END IF;
	     If l_qte_line_tbl(i).serviceable_product_flag = 'Y' then
             l_qte_line_prcd_parent(l_qte_line_id) := i;
	     end if;
          /*Assuming l_qte_line_tbl is the p_qte_line_tbl and data is always passed in the PL/SQL table*/
	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:service_item_flag:'
                         ||l_qte_line_tbl(i).service_item_flag,1,'Y');
          END IF;
          If l_qte_line_tbl(i).service_item_flag = 'Y' then
             l_qte_line_prcd_child(l_qte_line_id):= i;
          End if;

      END LOOP; --main End loop FOR i IN 1..l_qte_line_tbl.count

      /*Build relationship table: Only support Current quote*/
      If l_srv_line_dtl_tbl.count > 0 then
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	 aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:l_srv_line_dtl_tbl.count:'
					||l_srv_line_dtl_tbl.count,1,'Y');
      END IF;
      For j in 1..l_srv_line_dtl_tbl.count loop
      If (l_srv_line_dtl_tbl(j).SERVICE_REF_LINE_ID IS NOT NULL
           OR l_srv_line_dtl_tbl(j).SERVICE_REF_LINE_ID <> FND_API.G_MISS_NUM) Then
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:quote line id:'||l_srv_line_dtl_tbl(j).quote_line_id,1,'Y');
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:service ref line id:'||l_srv_line_dtl_tbl(j).service_ref_line_id,1,'Y');
      END IF;
              l_req_related_lines_tbl(j).line_index :=  l_qte_line_prcd_parent(l_srv_line_dtl_tbl(j).service_ref_line_id)+1;
              l_req_related_lines_tbl(j).LINE_DETAIL_INDEX := 0;
              l_req_related_lines_tbl(j).RELATED_LINE_INDEX := l_qte_line_prcd_child(l_srv_line_dtl_tbl(j).quote_line_id)+1;
              l_req_related_lines_tbl(j).RELATED_LINE_DETAIL_INDEX := 0;
              l_req_related_lines_tbl(j).RELATIONSHIP_TYPE_CODE :=QP_PREQ_GRP.G_SERVICE_LINE;
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:line_index :'
                                 ||l_req_related_lines_tbl(j).line_index, 1, 'Y');
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:related line_index: '
                                 ||l_req_related_lines_tbl(j).RELATED_LINE_INDEX , 1, 'Y');
              aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:RELATIONSHIP TYPE CODE: '
                                 ||l_req_related_lines_tbl(j).RELATIONSHIP_TYPE_CODE, 1, 'Y');
      END IF;
      END IF; --l_srv_line_dtl_tbl(j).SERVICE_REF_LINE_ID IS NOT NULL
      End Loop;
      End If;--l_srv_line_dtl_tbl.count > 0


      l_control_rec.pricing_event := p_control_rec.pricing_event;
      l_control_rec.calculate_flag := p_control_rec.calculate_flag;
      l_control_rec.simulation_flag := p_control_rec.simulation_flag;
      l_control_rec.TEMP_TABLE_INSERT_FLAG := 'Y';
      l_control_rec.source_order_amount_flag := 'Y';
      l_control_rec.GSA_CHECK_FLAG := 'Y';
      l_control_rec.GSA_DUP_CHECK_FLAG := 'Y';

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
      END IF;

      /*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar (MOAC)  */

      IF ((p_qte_header_rec.org_id IS NULL) OR (p_qte_header_rec.org_id = FND_API.G_MISS_NUM)) THEN
		IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_MISSING_OU');
			FND_MSG_PUB.ADD;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

     /*				End of Change                     (MOAC)                  */




      QP_PREQ_PUB.PRICE_REQUEST
                 (p_control_rec           => l_control_rec,
                  p_line_tbl              => l_Req_line_tbl,
                  p_qual_tbl              => l_Req_qual_tbl,
                  p_line_attr_tbl         => l_Req_line_attr_tbl,
                  p_line_detail_tbl       => l_req_line_detail_tbl,
                  p_line_detail_qual_tbl  => l_req_line_detail_qual_tbl,
                  p_line_detail_attr_tbl  => l_req_line_detail_attr_tbl,
                  p_related_lines_tbl     => l_req_related_lines_tbl,
                  x_line_tbl              => lx_req_line_tbl,
                  x_line_qual             => lx_Req_qual_tbl,
                  x_line_attr_tbl         => lx_Req_line_attr_tbl,
                  x_line_detail_tbl       => lx_req_line_detail_tbl,
                  x_line_detail_qual_tbl  => lx_req_line_detail_qual_tbl,
                  x_line_detail_attr_tbl  => lx_req_line_detail_attr_tbl,
                  x_related_lines_tbl     => lx_req_related_lines_tbl,
                  x_return_status         => l_return_status,
                  x_return_status_text    => l_return_status_text);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
        aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:After PRICE_REQUEST l_return_status:'
	                      ||l_return_status, 1, 'Y');
        aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:After PRICE_REQUEST l_return_status_text '
                           ||l_return_status_text,1,'N');
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*In lx_Req_line_tbl check for the return status for each line and then populate that status in
       **x_qte_line_tbl.
      */
      ASO_PRICING_INT.G_LINE_REC := NULL;
      ASO_PRICING_INT.G_HEADER_REC := NULL;
      /*Returning the same table back to the caller*/
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	    aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: After pricing call lx_qte_line_tbl.count:'
	                     ||nvl(lx_qte_line_tbl.count,0),1,'Y');
	 END IF;
	 x_qte_line_tbl := lx_qte_line_tbl;
	 /*In quote line table initialize the pricing_status_text to success*/
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:x_qte_line_tbl.count:'||x_qte_line_tbl.count,1,'N');
	 END IF;
	 k := x_qte_line_tbl.FIRST;
	 While k is not null loop
	   x_qte_line_tbl(k).pricing_status_code := FND_API.G_RET_STS_SUCCESS;
	   k := x_qte_line_tbl.NEXT(k);
	 end loop;

      /*Update all the errored records*/
      FOR C_status_code_rec in C_status_code LOOP
	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	       aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: C_status_code_rec.line_id:'
                               ||lx_req_line_rec.line_id,1,'N');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: C_status_code_rec.pricing_status_code:'
                               ||lx_req_line_rec.status_code,1,'N');
            aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: C_status_code_rec.pricing_status_text:'
                               ||lx_req_line_rec.status_text,1,'N');
	     END IF;

	     /*For this line_id update the pricing_status_code in the x_qte_line_tbl*/
		j := x_qte_line_tbl.FIRST;
		WHILE j IS NOT NULL LOOP
		   If C_status_code_rec.line_id = x_qte_line_tbl(j).quote_line_id then
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: Updating the quote_line_id: '
                                     ||x_qte_line_tbl(j).quote_line_id||' with status_code: '
                                     ||FND_API.G_RET_STS_ERROR,1,'N');
                END IF;
	           x_qte_line_tbl(j).pricing_status_code := FND_API.G_RET_STS_ERROR;
			 x_qte_line_tbl(j).pricing_status_text := C_status_code_rec.pricing_status_text;
			 exit;
             End If;
		   j := x_qte_line_tbl.NEXT(j);
		END LOOP; --End loop WHILE j IS NOT NULL LOOP
      END LOOP; --C_status_code_rec in C_status_code LOOP


      If l_call_flg = 'O' then
           For i in 1..x_qte_line_tbl.count loop
               x_qte_line_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
           end loop;
      End If;


  Else
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT: There are no quote lines for the price request validation',1,'N');
     END IF;
  End If; -- If l_qte_line_tbl.count > 0


 -- Standard check for p_commit
IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
END IF;

FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

for l in 1 .. x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_VALIDATE_PRICING_PVT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
end loop;


EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('after inside EXCEPTION  return status'||x_return_status, 1, 'Y');
      END IF;
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);


END;


End ASO_VALIDATE_PRICING_PVT;

/
