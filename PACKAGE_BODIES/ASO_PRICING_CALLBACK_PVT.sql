--------------------------------------------------------
--  DDL for Package Body ASO_PRICING_CALLBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICING_CALLBACK_PVT" as
/* $Header: asovpclb.pls 120.3.12010000.12 2016/01/22 16:36:12 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_CALLBACK_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PRICING_CALLBACK_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovpclb.pls';


PROCEDURE Config_Callback_Pricing_Order(
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
     x_qte_header_rec           OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_qte_line_dtl_tbl         OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
     x_price_adj_tbl            OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
     x_price_adj_attr_tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
     x_price_adj_rltship_tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Config_Callback_Pricing_Order';
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
    l_ln_price_attr_tbl           ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_qte_line_prcd               Index_Link_Tbl_Type;
    l_return_status               VARCHAR2(1);
    lv_return_status              VARCHAR2(1);
    l_return_status_text          VARCHAR2(2000);
    l_message_text                VARCHAR2(2000);
    lx_req_line_rec               QP_PREQ_GRP.LINE_REC_TYPE;
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    l_qte_header_rec              ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_price_attr_tbl              ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_dtl_tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_price_adj_tbl              ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_price_adj_attr_tbl         ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_price_adj_rltship_tbl      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    l_qte_line_rec                ASO_QUOTE_PUB.Qte_Line_rec_Type;
    G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: Start of Config_Callback_Pricing_Order.....',1,'Y');
END IF;
-- Standard Start of API savepoint
SAVEPOINT ASO_PRICING_CALLBACK_PVT;

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
   aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin FND_API.to_Boolean'||p_init_msg_list, 1, 'Y');
 END IF;
 FND_MSG_PUB.initialize;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_control_rec.request_type:'||p_control_rec.request_type,1,'N');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'N');
END IF;
l_request_type := p_control_rec.request_type;
l_pricing_event := p_control_rec.pricing_event;

ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
         p_qte_header_rec     => p_qte_header_rec,
         p_shipment_rec       => p_hd_shipment_rec);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:QP_ATTR_MAPPING_PUB.Build_Contexts Starts',1,'Y');
END IF;
QP_ATTR_MAPPING_PUB.Build_Contexts (
             P_REQUEST_TYPE_CODE          => l_request_type,
             P_PRICING_TYPE               => 'H',
             X_PRICE_CONTEXTS_RESULT_TBL  => l_hd_pricing_contexts_tbl,
             X_QUAL_CONTEXTS_RESULT_TBL   => l_hd_qual_contexts_tbl);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:QP_ATTR_MAPPING_PUB.Build_Contexts Ends',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Copy_Attribs_To_Req Starts',1,'Y');
END IF;

Copy_Attribs_To_Req (
         p_line_index             => 1,
         p_pricing_contexts_tbl   => l_hd_pricing_contexts_tbl,
         p_qualifier_contexts_tbl => l_hd_qual_contexts_tbl,
         px_req_line_attr_tbl     => l_req_line_attr_tbl,
         px_req_qual_tbl          => l_req_qual_tbl);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Copy_Attribs_To_Req Ends',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Append_asked_for Starts',1,'Y');
END IF;

Append_asked_for(
            p_header_id            => p_qte_header_rec.quote_header_id
            ,p_line_index          => 1
            ,px_Req_line_attr_tbl  => l_Req_line_attr_tbl
            ,px_Req_qual_tbl          => l_Req_qual_tbl);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Append_asked_for Ends',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Copy_Header_To_Request Starts',1,'Y');
END IF;

Copy_Header_To_Request(
            p_Request_Type        => l_request_type,
            p_pricing_event       => l_pricing_event,
            p_header_rec          => p_qte_header_rec,
            px_req_line_tbl       => l_Req_line_tbl);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Copy_Header_To_Request Ends',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_qte_header_rec.quote_header_id:'||p_qte_header_rec.quote_header_id,1,'N');
END IF;

l_qte_line_tbl := p_qte_line_tbl;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: l_qte_line_tbl.count'|| l_qte_line_tbl.count, 1, 'N');
END IF;
If l_qte_line_tbl.count > 0 Then

     FOR i IN 1..l_qte_line_tbl.count LOOP/*Main Loop for preparing Lines from Quote in the Price Req Strcture*/
       l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;

       If (l_qte_line_tbl(i).price_list_id is null
          OR l_qte_line_tbl(i).price_list_id= FND_API.G_MISS_NUM) Then
             l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
       End if;

       l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
       IF l_qte_line_dtl_tbl.count = 1 THEN
             l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
       END IF;

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the G_LINE_REC', 1, 'Y');
       END IF;
       ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                          p_qte_line_rec               => l_qte_line_tbl(i),
                          p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                          p_shipment_rec               => l_shipment_rec);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the G_LINE_REC', 1, 'Y');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the Build_Contexts', 1, 'Y');
       END IF;
       QP_ATTR_MAPPING_PUB.Build_Contexts (
                          P_REQUEST_TYPE_CODE           => l_request_type,
                          P_PRICING_TYPE                => 'L',
                          X_PRICE_CONTEXTS_RESULT_TBL   => l_pricing_contexts_tbl,
                          X_QUAL_CONTEXTS_RESULT_TBL    => l_qual_contexts_tbl);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the Build_Contexts', 1, 'Y');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the Copy_Attribs_To_Req', 1, 'Y');
       END IF;
       Copy_Attribs_To_Req (
                          p_line_index                  => i+1,
                          p_pricing_contexts_tbl        => l_pricing_contexts_tbl,
                          p_qualifier_contexts_tbl      => l_qual_contexts_tbl,
                          px_req_line_attr_tbl          => l_req_line_attr_tbl,
                          px_req_qual_tbl               => l_req_qual_tbl);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the Copy_Attribs_To_Req', 1, 'Y');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the Copy_hdr_attr_to_line', 1, 'Y');
       END IF;
       Copy_hdr_attr_to_line (
                          p_line_index                  => i+1,
                          p_pricing_contexts_tbl        => l_hd_pricing_contexts_tbl,
                          p_qualifier_contexts_tbl      => l_hd_qual_contexts_tbl,
                          px_req_line_attr_tbl          => l_req_line_attr_tbl,
                          px_req_qual_tbl               => l_req_qual_tbl);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the Copy_hdr_attr_to_line', 1, 'Y');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the Append_asked_for', 1, 'Y');
       END IF;
       Append_asked_for(
                          p_header_id                   => p_qte_header_rec.quote_header_id
                          ,p_line_id                    => l_qte_line_tbl(i).quote_line_id
                          ,p_line_index                 => i+1
                          ,px_Req_line_attr_tbl         => l_Req_line_attr_tbl
                          ,px_Req_qual_tbl              => l_Req_qual_tbl);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the Append_asked_for', 1, 'Y');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin Setting up the Copy_Line_To_Request', 1, 'Y');
       END IF;
       Copy_Line_To_Request(
                          p_Request_Type                => l_request_type,
                          p_pricing_event               => l_pricing_event,
                          p_line_rec                    => l_qte_line_tbl(i),
                          p_line_dtl_rec                => l_qte_line_dtl_rec,
                          p_control_rec                 => p_control_rec,
                          px_req_line_tbl               => l_Req_line_tbl);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End Setting up the Copy_Line_To_Request', 1, 'Y');
       END IF;
    END LOOP; --main End loop FOR i IN 1..l_qte_line_tbl.count

    l_control_rec.pricing_event := p_control_rec.pricing_event;
    l_control_rec.calculate_flag := p_control_rec.calculate_flag;
    l_control_rec.simulation_flag := p_control_rec.simulation_flag;
    l_control_rec.TEMP_TABLE_INSERT_FLAG := 'Y';
    l_control_rec.source_order_amount_flag := 'Y';
    l_control_rec.GSA_CHECK_FLAG := 'Y';
    l_control_rec.GSA_DUP_CHECK_FLAG := 'Y';

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
END IF;
/*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar (MOAC)    */

	       l_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

/*				End of Change                       (MOAC)             */


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
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:After PRICE_REQUEST l_return_status:'||l_return_status, 1, 'N');
  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:After PRICE_REQUEST l_return_status_text '||l_return_status_text,1,'N');
END IF;

ASO_PRICING_INT.G_LINE_REC := NULL;
ASO_PRICING_INT.G_HEADER_REC := NULL;

i := lx_req_line_tbl.FIRST;
WHILE i IS NOT NULL LOOP
      lx_req_line_rec := lx_req_line_tbl(i);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      If lx_req_line_rec.status_code in(QP_PREQ_GRP.g_status_invalid_price_list,
               QP_PREQ_GRP.g_sts_lhs_not_found,
               QP_PREQ_GRP.g_status_formula_error,QP_PREQ_GRP.g_status_other_errors,
               fnd_api.g_ret_sts_unexp_error,fnd_api.g_ret_sts_error,
               QP_PREQ_GRP.g_status_calc_error,QP_PREQ_GRP.g_status_uom_failure,
               QP_PREQ_GRP.g_status_invalid_uom,QP_PREQ_GRP.g_status_dup_price_list,
               QP_PREQ_GRP.g_status_invalid_uom_conv,QP_PREQ_GRP.g_status_invalid_incomp,
               QP_PREQ_GRP.g_status_best_price_eval_error,
               QP_PREQ_PUB.g_back_calculation_sts) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      If lx_req_line_rec.status_code = QP_PREQ_GRP.G_STATUS_GSA_VIOLATION Then
         IF FND_PROFILE.value('ASO_GSA_PRICING') = 'ERROR' THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_GSA_VIOLATION');
            FND_MSG_PUB.ADD;
         END IF;

         IF FND_PROFILE.value('ASO_GSA_PRICING') = 'WARNING' THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_GSA_VIOLATION');
            FND_MSG_PUB.ADD;
         END IF;
     End if;

     If lx_req_line_rec.status_code <>QP_PREQ_GRP.G_STATUS_GSA_VIOLATION Then
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                   FND_MESSAGE.Set_Token('ROW', 'ASO_PRICING_CALLBACK_PVT AFTER PRICING CALL', TRUE);
                   FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSE
                l_message_text := lx_req_line_rec.status_code || ': '||lx_req_line_rec.status_text;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:After GSA Violation  QP ERROR '||l_message_text, 1, 'Y');
                END IF;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
                   FND_MESSAGE.Set_Token('MSG_TXT', substr(l_message_text, 1,255), FALSE);
                   FND_MSG_PUB.ADD;
                END IF;
             END IF;
            lv_return_status := x_return_status;
         END IF;
      END If;
      i :=  lx_req_line_tbl.NEXT(i);
 END LOOP; -- End loop WHILE i IS NOT NULL LOOP

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Before Copy_Request_To_Quote', 1, 'Y');
 END IF;
 Copy_Request_To_Quote(
      p_req_line_tbl              => lx_req_line_tbl,
      p_req_line_qual             => lx_Req_qual_tbl,
      p_req_line_attr_tbl         => lx_Req_line_attr_tbl,
      p_req_line_detail_tbl       => lx_req_line_detail_tbl,
      p_req_line_detail_qual_tbl  => lx_req_line_detail_qual_tbl,
      p_req_line_detail_attr_tbl  => lx_req_line_detail_attr_tbl,
      p_req_related_lines_tbl     => lx_req_related_lines_tbl,
      p_qte_header_rec            => p_qte_header_rec,
      p_qte_line_tbl              => l_qte_line_tbl,
      p_qte_line_dtl_tbl          => ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl,
      x_qte_header_rec            => lx_qte_header_rec,
      x_qte_line_tbl              => lx_qte_line_tbl,
      x_qte_line_dtl_tbl          => lx_qte_line_dtl_tbl,
      x_price_adj_tbl             => lx_price_adj_tbl,
      x_price_adj_attr_tbl        => lx_price_adj_attr_tbl,
      x_price_adj_rltship_tbl     => lx_price_adj_rltship_tbl);
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:after Copy_Request_To_Quote', 1, 'Y');
 END IF;

 x_qte_line_tbl        := lx_qte_line_tbl;

 IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := lv_return_status;
    RAISE FND_API.G_EXC_ERROR;
 End If;

End If; --l_qte_line_tbl.count


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
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:After inside EXCEPTION  return status'||x_return_status, 1, 'N');
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

END Config_Callback_Pricing_Order;


PROCEDURE Config_Callback_Pricing_Order (
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec                IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
        p_qte_line_tbl               IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_qte_header_id              IN   NUMBER,
        x_return_status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'Config_Callback_Pricing_Order';
    l_api_version_number            CONSTANT NUMBER   := 1.0;
    l_control_rec                   QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
    l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_hd_pricing_contexts_Tbl       QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_hd_qual_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_pricing_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_qual_contexts_Tbl             QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    lx_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
    lx_req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
    lx_req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    lx_req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    lx_req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    lx_req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    lx_req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_qte_header_rec              ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_shipment_tbl                  ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_shipment_rec                  ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_price_attr_tbl                ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_qte_line_tbl                  ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_id                   NUMBER;
    l_qte_line_dtl_rec              ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_qte_line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_return_status                 VARCHAR2(1);
    l_return_status_text            VARCHAR2(2000);
    l_request_type                  VARCHAR2(60);
    l_pricing_event                 VARCHAR2(30);
    l_qte_line_rec                  ASO_QUOTE_PUB.Qte_Line_rec_Type;
    lx_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_line_tbl                 ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_dtl_tbl             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_price_adj_tbl                ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_price_adj_attr_tbl           ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_price_adj_rltship_tbl        ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    l_qte_line_prcd                 Index_Link_Tbl_Type;
    l_message_text                  VARCHAR2(2000);
    lx_req_line_rec                 QP_PREQ_GRP.LINE_REC_TYPE;
    i                               BINARY_INTEGER;
    ln_shipment_tbl                 ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_line_rltship_tbl              ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    l_ln_price_attr_tbl             ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_hd_shipment_rec               ASO_QUOTE_PUB.Shipment_Rec_Type;
    lx_return_status                VARCHAR2(50);
    lx_msg_count                    NUMBER;
    lx_msg_data                     VARCHAR2(2000);

BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: In Config_Callback_Pricing_Order with HDR Id CALL', 1, 'Y');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT ASO_PRICING_CALLBACK_PVT;

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
          FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_request_type := p_control_rec.request_type;
    l_pricing_event := p_control_rec.pricing_event;

    l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_id);
    l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_id,NULL);
    IF l_shipment_tbl.count = 1 THEN
      l_shipment_rec := l_shipment_tbl(1);
    END IF;
    l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(p_qte_header_id, null);
    ASO_PRICING_CALLBACK_PVT.Config_Callback_Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => FND_API.G_FALSE,
                    P_Commit                 => FND_API.G_FALSE,
                    p_control_rec            => p_control_rec,
                    p_qte_header_rec         => l_qte_header_rec,
                    p_hd_shipment_rec        => l_shipment_rec,
                    p_hd_price_attr_tbl      => l_price_attr_tbl,
                    p_qte_line_tbl           =>    p_qte_line_tbl,
                    p_line_rltship_tbl       => l_line_rltship_tbl,
                    p_qte_line_dtl_tbl       => l_qte_line_dtl_tbl,
                    p_ln_shipment_tbl        => ln_shipment_tbl,
                    p_ln_price_attr_tbl      => l_ln_price_attr_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          =>     lx_price_adj_tbl,
                    x_price_adj_attr_tbl     => lx_price_adj_attr_tbl,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
      COMMIT WORK;
      END IF;

   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
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

END Config_Callback_Pricing_Order;


PROCEDURE Copy_Attribs_To_Req(
    p_line_index                            number,
    p_pricing_contexts_Tbl                  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl                QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    l_attr_index    number := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index    number := nvl(px_Req_qual_tbl.last,0);
BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: In copy attribs to req - Global Header Rec quote_status_id'
                         ||ASO_PRICING_INT.G_HEADER_REC.quote_status_id,1,'N');
    END IF;
    for i in 1..p_pricing_contexts_Tbl.count loop
        l_attr_index := l_attr_index +1;
        IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
        ELSE
            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'Y';
        END IF;
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
        IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
               px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'N';
        ELSE
               px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'Y';
        END IF;
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
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    l_attr_index              number := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index              number := nvl(px_Req_qual_tbl.last,0);
    copy_hdr_rec_to_line_flag boolean := TRUE;
BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: copy_hdr_attribs_to_line - Global Header Rec quote_status_id:'
                         ||ASO_PRICING_INT.G_HEADER_REC.quote_status_id,1,'N');
    END IF;
    for i in 1..p_pricing_contexts_Tbl.count loop
        l_attr_index := l_attr_index +1;
        IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
        ELSE
            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'Y';
        END IF;
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
           IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                 px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'N';
           ELSE
                 px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'Y';
           END IF;
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

procedure  Append_asked_for(
       p_header_id                             number := null
       ,p_Line_id                              number := null
       ,p_line_index                           number
       ,px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
       ,px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
i                  pls_integer;
l_price_list_id    NUMBER;

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
    from aso_price_attributes a
    where ( a.QUOTE_HEADER_ID = p_header_id )
    and (p_header_id is not null and p_header_id <> FND_API.G_MISS_NUM)
    and a.quote_line_id is null
    /*
     * New Code - Union is changed to union all
     */
  UNION ALL
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
    from aso_price_attributes a
    where ( a.QUOTE_line_id = p_line_id )
    and (p_line_id is not null and p_line_id <> FND_API.G_MISS_NUM);

begin
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT: In PL/SQL tbl,append_asked_for - Global_Header_Rec quote_status_id'
                         ||ASO_PRICING_INT.G_HEADER_REC.quote_status_id,1,'N');
    END IF;
    for asked_for_rec in asked_for_cur loop
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In append_asked_for  asked_for_rec.PRICING_ATTRIBUTE1'
                             ||asked_for_rec.PRICING_ATTRIBUTE1,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In append_asked_for  asked_for_rec.flex_title'
                             ||asked_for_rec.flex_title,1,'Y');
        END IF;
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
      if asked_for_rec.PRICING_ATTRIBUTE1 is not null then -- Promotion
             i := px_Req_Qual_Tbl.count+1;
             px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
             IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                px_Req_Qual_Tbl(i).Validated_Flag := 'N';
             ELSE
                px_Req_Qual_Tbl(i).Validated_Flag := 'Y';
             END IF;
             px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
             px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE1';
             px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE1;
      end if;
      if asked_for_rec.PRICING_ATTRIBUTE2 is not null then --Deal Component
             i := px_Req_Qual_Tbl.count+1;
             px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
              --px_Req_Qual_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
             IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                  px_Req_Qual_Tbl(i).Validated_Flag := 'N';
             ELSE
                  px_Req_Qual_Tbl(i).Validated_Flag := 'Y';
             END IF;
             px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
             px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE2';
             px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE2;
      end if;
      if asked_for_rec.PRICING_ATTRIBUTE3 is not null then -- Coupons
             i := px_Req_Qual_Tbl.count+1;
             px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
             --px_Req_Qual_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
             IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                  px_Req_Qual_Tbl(i).Validated_Flag := 'N';
             ELSE
                  px_Req_Qual_Tbl(i).Validated_Flag := 'Y';
             END IF;
             px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
             px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE3';
             px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE3;
      end if;
  end if;
end loop;

end Append_asked_for;


procedure  Append_asked_for(
    p_line_index                           NUMBER,
    p_pricing_attr_tbl                     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    px_Req_line_attr_tbl    in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */  QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    i                  NUMBER;
    l_price_list_id    NUMBER;
    l_pricing_attr_rec ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
BEGIN
    FOR j IN 1..p_pricing_attr_tbl.count LOOP
    l_pricing_attr_rec := p_pricing_attr_tbl(j);
    IF l_pricing_attr_rec.flex_title = 'QP_ATTR_DEFNS_PRICING' THEN
       if l_pricing_attr_rec.PRICING_ATTRIBUTE1 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE1 <> FND_API.G_MISS_CHAR then
          i := px_Req_line_attr_tbl.count+1;
          px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
          px_Req_line_attr_tbl(i).Validated_Flag := 'N';
          px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
          px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE1';
          px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE1;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE2  is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE2 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE2';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE2;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE3 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE3 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE3';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE3;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE4 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE4 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE4';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE4;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE5 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE5 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE5';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE5;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE6 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE6 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE6';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE6;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE7 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE7 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE7';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE7;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE8 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE8 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE8';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE8;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE9 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE9 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE9';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE9;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE10 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE10 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE10';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE10;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE11 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE11 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE11';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE11;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE12 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE12 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE12';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE12;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE13 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE13 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE13';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE13;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE14 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE14 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE14';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE14;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE15 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE15 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE15';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE15;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE16 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE16 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE16';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE16;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE17 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE17 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE17';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE17;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE18 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE18 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE18';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE18;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE19 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE19 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE19';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE19;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE20 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE20 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE20;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE21 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE21 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE21';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE21;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE22 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE22 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE22';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE22;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE23 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE23 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE23';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE23;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE24 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE24 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE24';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE24;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE25 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE25 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE25';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE25;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE26 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE26 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE26';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE26;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE27 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE27 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE27';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE27;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE28 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE28 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE28';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE28;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE29 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE29 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE29';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE29;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE30 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE30 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE30';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE30;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE31 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE31 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE31';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE31;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE32 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE32 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE32';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE32;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE33 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE33 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE33';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE33;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE34 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE34 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE34';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE34;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE35 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE35 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE35';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE35;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE36 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE36 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE36';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE36;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE37 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE37 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE37';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE37;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE38 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE38 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE38';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE38;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE39 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE39 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE39';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE39;
         end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE40 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE40 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE40';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE40;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE41 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE41 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE41';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE41;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE42 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE42 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE42';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE42;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE43 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE43 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE43';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE43;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE44 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE44 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE44';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE44;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE45 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE45 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE45';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE45;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE46 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE46 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE46';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE46;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE47 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE47 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE47';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE47;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE48 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE48 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE48';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE48;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE49 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE49 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE49';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE49;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE50 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE50 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE50';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE50;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE51 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE51 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE51';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE51;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE52 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE52 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE52';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE52;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE53 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE53 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE53';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE53;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE54 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE54 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE54';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE54;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE55 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE55 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE55';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE55;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE56 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE56 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE56';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE56;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE57 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE57 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE57';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE57;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE58 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE58 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE58';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE58;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE59 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE59 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE59';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE59;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE60 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE60 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE60';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE60;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE61 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE61 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE61';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE61;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE62 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE62 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE62';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE62;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE63 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE63 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE63';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE63;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE64 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE64 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE64';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE64;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE65 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE65 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE65';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE65;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE66 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE66 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE66';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE66;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE67 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE67 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE67';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE67;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE68 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE68 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE68';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE68;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE69 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE69 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE69';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE69;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE70 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE70 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE70';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE70;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE71 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE71 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE71';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE71;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE72 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE72 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE72';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE72;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE73 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE73 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE73';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE73;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE74 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE74 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE74';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE74;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE75 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE75 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE75';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE75;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE76 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE76 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE76';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE76;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE77 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE77 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE77';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE77;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE78 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE78 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE78';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE78;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE79 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE79 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE79';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE79;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE80 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE80 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE80';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE80;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE81 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE81 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE81';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE81;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE82 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE82 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE82';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE82;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE83 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE83 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE83';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE83;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE84 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE84 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE84';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE84;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE85 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE85 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE85';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE85;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE86 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE86 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE86';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE86;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE87 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE87 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE87';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE87;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE88 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE88 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE88';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE88;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE89 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE89 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE89';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE89;
        end if;

        if l_pricing_attr_rec.PRICING_ATTRIBUTE90 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE90 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE90';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE90;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE91 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE91 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE91';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE91;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE92 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE92 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE92';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE92;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE93 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE93 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE93';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE93;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE94 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE94 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE94';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE94;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE95 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE95 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE95';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE95;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE96 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE96 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE96';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE96;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE97 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE97 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE97';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE97;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE98 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE98 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE98';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE98;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE99 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE99 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE99';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=l_pricing_attr_rec.PRICING_ATTRIBUTE99;
        end if;
        if l_pricing_attr_rec.PRICING_ATTRIBUTE100 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE100 <> FND_API.G_MISS_CHAR  then
            i := px_Req_line_attr_tbl.count+1;
            px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
            px_Req_line_attr_tbl(i).Validated_Flag := 'N';
            px_Req_line_attr_tbl(i).pricing_context := l_pricing_attr_rec.pricing_context;
            px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE100';
            px_Req_line_attr_tbl(i).Pricing_Attr_Value_From:=l_pricing_attr_rec.PRICING_ATTRIBUTE100;
        end if;

    ELSE -- Copy the Qualifiers

       if ( l_pricing_attr_rec.PRICING_ATTRIBUTE1 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE1 <> FND_API.G_MISS_CHAR   )then -- Promotion
            i := px_Req_Qual_Tbl.count+1;
            px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
            px_Req_Qual_Tbl(i).Validated_Flag := 'N';
            px_Req_Qual_Tbl(i).Qualifier_Context := l_pricing_attr_rec.pricing_context;
            px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE1';
            px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE1;
       end if;

      if (l_pricing_attr_rec.PRICING_ATTRIBUTE2 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE2 <> FND_API.G_MISS_CHAR  ) then --Deal Component
          i := px_Req_Qual_Tbl.count+1;
          px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
          px_Req_Qual_Tbl(i).Validated_Flag := 'N';
          px_Req_Qual_Tbl(i).Qualifier_Context := l_pricing_attr_rec.pricing_context;
          px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE2';
          px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE2;
      end if;
      if (l_pricing_attr_rec.PRICING_ATTRIBUTE3 is not null and l_pricing_attr_rec.PRICING_ATTRIBUTE3 <> FND_API.G_MISS_CHAR  ) then -- Coupons
            i := px_Req_Qual_Tbl.count+1;
            px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
            px_Req_Qual_Tbl(i).Validated_Flag := 'N';
            px_Req_Qual_Tbl(i).Qualifier_Context := l_pricing_attr_rec.pricing_context;
            px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE3';
            px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := l_pricing_attr_rec.PRICING_ATTRIBUTE3;
       end if;
    end if;
    end loop;
end Append_asked_for;



procedure copy_Header_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_header_rec                        ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */             QP_PREQ_GRP.LINE_TBL_TYPE)
IS
BEGIN
    px_req_line_tbl(1).REQUEST_TYPE_CODE := p_Request_Type;
    px_req_line_tbl(1).PRICING_EVENT := p_pricing_event;
    px_req_line_tbl(1).LINE_INDEX := 1;
    px_req_line_tbl(1).LINE_TYPE_CODE := 'ORDER';
    px_req_line_tbl(1).CURRENCY_CODE := p_Header_rec.currency_code;
    px_req_line_tbl(1).PRICE_FLAG := 'Y';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:g_header_rec.PRICE_FROZEN_DATE '||ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE,1,'N');
    END IF;
    /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
    if ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE = FND_API.G_MISS_DATE
       OR ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE is NULL then
            px_req_line_tbl(1).PRICING_EFFECTIVE_DATE := trunc(sysdate);
    else
            px_req_line_tbl(1).PRICING_EFFECTIVE_DATE := trunc(ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE);
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Header Request copy In else: px_req_line_tbl(1).PRICING_EFFECTIVE_DATE '
                                 ||px_req_line_tbl(1).PRICING_EFFECTIVE_DATE,1,'N');
            END IF;
    end if;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Header Request copy: px_req_line_tbl(1).PRICING_EFFECTIVE_DATE '
                         ||px_req_line_tbl(1).PRICING_EFFECTIVE_DATE,1,'N');
    END IF;
end Copy_Header_To_Request;

procedure copy_Line_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_line_rec                          ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_line_dtl_rec                      ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_control_rec      IN               ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */             QP_PREQ_GRP.LINE_TBL_TYPE)
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
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Copy line to req p_Line_rec.SELLING_PRICE_CHANGE  '
                         ||p_Line_rec.SELLING_PRICE_CHANGE,1,'Y');
    END IF;
    If p_Line_rec.SELLING_PRICE_CHANGE = 'Y' then
       l_req_line_rec.UPDATED_ADJUSTED_UNIT_PRICE := p_Line_rec.line_quote_price;
    End If;

    -- Bug 2430534.Should set this flag only for child service line, normal line to 'Y'
    -- If the line is from order or customer product set it to 'N'.

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Copy line to req p_Line_rec.LINE_CATEGORY_CODE  :'
                         ||p_Line_rec.LINE_CATEGORY_CODE,1,'Y');
    END IF;
    IF p_Line_rec.LINE_CATEGORY_CODE IN ('SERVICE_REF_ORDER_LINE','SERVICE_REF_CUSTOMER_LINE') THEN
    	l_req_line_rec.PRICE_FLAG := 'N';
    ELSE
    	l_req_line_rec.PRICE_FLAG := 'Y';
    END IF;
    /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
    if ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE = FND_API.G_MISS_DATE
       OR ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE is NULL then
          l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(sysdate);
    else
          l_req_line_rec.PRICING_EFFECTIVE_DATE := trunc(ASO_PRICING_INT.g_header_rec.PRICE_FROZEN_DATE);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Line Request copy in Else: l_req_line_rec.PRICING_EFFECTIVE_DATE '
                               ||l_req_line_rec.PRICING_EFFECTIVE_DATE,1,'N');
          END IF;
    end if;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Line Request copy: l_req_line_rec.PRICING_EFFECTIVE_DATE '
                         ||l_req_line_rec.PRICING_EFFECTIVE_DATE,1,'N');
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:copy line request: p_Line_rec.CHARGE_PERIODICITY_CODE '
                         ||p_Line_rec.CHARGE_PERIODICITY_CODE,1,'N');
    END IF;
    l_req_line_rec.CHARGE_PERIODICITY_CODE := p_Line_rec.CHARGE_PERIODICITY_CODE;

    px_req_line_tbl(px_req_line_tbl.count+1) := l_req_line_rec;
end copy_Line_to_request;

PROCEDURE Copy_Request_To_Quote(
    p_req_line_tbl                IN  QP_PREQ_GRP.LINE_TBL_TYPE,
    p_req_line_qual               IN  QP_PREQ_GRP.QUAL_TBL_TYPE,
    p_req_line_attr_tbl           IN  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    p_req_line_detail_tbl         IN  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
    p_req_line_detail_qual_tbl    IN  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    p_req_line_detail_attr_tbl    IN  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    p_req_related_lines_tbl       IN  QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
    p_qte_header_rec              IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_qte_line_tbl                IN  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    p_qte_line_dtl_tbl            IN  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    x_qte_header_rec              OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    x_qte_line_tbl                OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    x_qte_line_dtl_tbl            OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    x_price_adj_tbl               OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    x_price_adj_attr_tbl          OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
    x_price_adj_rltship_tbl       OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type)
IS
    l_index                   NUMBER;
    l_req_line_rec            QP_PREQ_GRP.LINE_REC_TYPE;
    l_req_line_dtl_rec        QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;
    l_qte_line_rec            ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    i                         BINARY_INTEGER;
    j                         BINARY_INTEGER;
    l_base_price              NUMBER := FND_API.G_MISS_NUM;
    l_price_adj_rltship_rec   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
    l_qte_line_prcd           Index_Link_Tbl_Type;
    l_price_adj_prcd          Index_Link_Tbl_Type;
    lx_price_adj_prcd         Index_Link_Tbl_Type;
    l_message_text            VARCHAR2(2000);
    l_count1                  NUMBER;
    l_my_index                NUMBER;

BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Begin In Copy_Request_To_Quote', 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Building the qte line table.....'||p_req_line_tbl.count,1,'N');
    END IF;
    i := p_req_line_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
      l_req_line_rec := p_req_line_tbl(i);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Copy_Request_To_Quote:line_type_code - '
                           ||l_req_line_rec.line_type_code, 1, 'N');
      END IF;
      IF l_req_line_rec.line_type_code = 'LINE'  then
           IF p_qte_line_tbl.EXISTS(l_req_line_rec.line_index-1) THEN
              l_qte_line_rec := p_qte_line_tbl(l_req_line_rec.line_index-1);
           END IF;
           l_qte_line_rec.operation_code := 'UPDATE';
           l_qte_line_rec.line_quote_price := NVL(l_req_line_rec.adjusted_unit_price,
                                                                  l_req_line_rec.unit_price);
           l_qte_line_rec.line_list_price := l_req_line_rec.unit_price ;
           l_qte_line_rec.line_adjusted_amount := l_qte_line_rec.line_quote_price
                                                         - l_qte_line_rec.line_list_price;

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Copy Req to Quote line_list_price: '
                                ||l_qte_line_rec.line_list_price,1,'N');
             aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Copy Req to Quote line_adjusted_amount: '
                                ||l_qte_line_rec.line_adjusted_amount,1,'N');
           END IF;

           IF l_qte_line_rec.line_list_price <> 0 THEN
              l_qte_line_rec.line_adjusted_percent :=
                    (l_qte_line_rec.line_adjusted_amount/l_qte_line_rec.line_list_price)*100;
           END IF;
           l_qte_line_rec.quantity := l_req_line_rec.priced_quantity ;
           l_qte_line_rec.uom_code := l_req_line_rec.priced_uom_code ;

           x_qte_line_tbl(x_qte_line_tbl.count+1) := l_qte_line_rec;
           l_qte_line_prcd(i) := x_qte_line_tbl.count;
        ELSE
            NULL;
      END IF;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:*********************NEXT LINE********************************',1,'N');
      END IF;
      i :=  p_req_line_tbl.NEXT(i);
    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Building the detail line tbl.....',1,'N');
    END IF;
    i := p_req_line_detail_tbl.FIRST;
    l_my_index := 1;
    WHILE I IS NOT NULL LOOP
      l_index := p_req_line_detail_Tbl(i).line_index;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Status_code for line_detail_tbl: '
                           ||p_req_line_tbl(l_index).status_code,1,'N');
      END IF;
      IF p_req_line_tbl(l_index).status_code in (
                                          QP_PREQ_GRP.G_STATUS_UPDATED,
                                          QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                          QP_PREQ_GRP.G_STATUS_UNCHANGED)
      THEN
          l_req_line_dtl_rec := p_req_line_detail_Tbl(i);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Req_Line_dtl_rec.created_from_list_type_code:'
                               ||l_req_line_dtl_rec.created_from_list_type_code, 1, 'N');
            aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Req_Line_dtl_rec.list_line_type_code:'
                               ||l_req_line_dtl_rec.list_line_type_code, 1, 'N');
          END IF;
          IF l_req_line_dtl_rec.created_from_list_type_code in ('PRL','AGR')
             AND l_req_line_dtl_rec.list_line_type_code in ( 'PLL','PBH') THEN
             --education change: changed to priced_price_list_id instead of price_list_id
             x_qte_line_tbl(l_qte_line_prcd(l_index)).priced_price_list_id :=
                                                      l_req_line_dtl_rec.list_header_id;
          End IF;
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_req_line_tbl(l_index).line_type_code:'
                               ||p_req_line_tbl(l_index).line_type_code, 1, 'N');
          END IF;
          IF l_req_line_dtl_rec.created_from_list_type_code in ('PRL','AGR') AND
             l_req_line_dtl_rec.list_line_type_code in( 'PLL') THEN
             NULL;
          ELSIF p_req_line_tbl(l_index).line_type_code = 'ORDER' THEN
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In elseif Req_Line_dtl_rec.created_from_list_type_code:'
                                         ||l_req_line_dtl_rec.created_from_list_type_code, 1, 'N');
                  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In elseif Req_Line_dtl_rec.LIST_LINE_ID:'
                                     ||l_req_line_dtl_rec.LIST_LINE_ID, 1, 'N');
                  aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:IF p_req_line_tbl(l_index).line_type_code is ORDER:'
                                     ||p_req_line_tbl(l_index).line_type_code,1, 'N');
                END IF;
                Copy_Req_Dtl_To_Price_Adj(
                                p_qte_header_rec           => p_qte_header_rec,
                                p_req_line_dtl_index       => i,
                                p_req_line_detail_rec      => l_req_line_dtl_rec,
                                p_req_line_detail_qual_tbl => p_req_line_detail_qual_tbl,
                                p_req_line_detail_attr_tbl => p_req_line_detail_attr_tbl,
                                px_price_adj_tbl           => x_price_adj_tbl,
                                px_price_adj_attr_tbl      => x_price_adj_attr_tbl,
                                px_price_adj_prcd          => l_price_adj_prcd);
         ELSE
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Else  Req_Line_dtl_rec.created_from_list_type_code:'
                                  ||l_req_line_dtl_rec.created_from_list_type_code, 1, 'N');
               aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In elseif Req_Line_dtl_rec.LIST_LINE_ID:'
                                  ||l_req_line_dtl_rec.LIST_LINE_ID, 1, 'N');
               aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:In Else If p_req_line_tbl(l_index).line_type_code is not Order:'
                                  ||p_req_line_tbl(l_index).line_type_code,1,'N');
             END IF;
             Copy_Req_Dtl_To_Price_Adj(
                               p_qte_line_index            => l_index-1,
                               p_qte_line_rec              => x_qte_line_tbl(l_qte_line_prcd(l_index)),
                               p_req_line_dtl_index        => i,
                               p_req_line_detail_rec       => l_req_line_dtl_rec,
                               p_req_line_detail_qual_tbl  => p_req_line_detail_qual_tbl,
                               p_req_line_detail_attr_tbl  => p_req_line_detail_attr_tbl,
                               px_price_adj_tbl            => x_price_adj_tbl,
                               px_price_adj_attr_tbl       => x_price_adj_attr_tbl,
                               px_price_adj_prcd           => l_price_adj_prcd);
         END IF;
         lx_price_adj_prcd(i):= x_price_adj_tbl.count;
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:i: lx_price_adj_prcd(i): '||i||': '||lx_price_adj_prcd(i),1,'N');
         END IF;
      END IF;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:***************************NEXT ADJUST***************************',1,'N');
      END IF;
      i :=  p_req_line_detail_tbl.NEXT(i);
  END LOOP;

/*Building the related adjustment record*/
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Building the  p_req_related_lines_tbl with no of rec:'
                     ||p_req_related_lines_tbl.count,1,'N');
  END IF;
  i := p_req_related_lines_tbl.FIRST;
  WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Req_Line_dtl_rec.Relationship_Type_Code:'
                         ||p_Req_Related_Lines_Tbl(i).Relationship_Type_Code, 1, 'N');
    END IF;
    IF p_Req_Related_Lines_Tbl(i).Relationship_Type_Code
       IN (QP_PREQ_GRP.G_PBH_LINE ,QP_PREQ_GRP.G_GENERATED_LINE )
       AND p_req_related_lines_tbl(i).LINE_DETAIL_INDEX is not null
       AND p_req_related_lines_tbl(i).RELATED_LINE_DETAIL_INDEX is not null
       AND lx_price_adj_prcd.EXISTS(p_req_related_lines_tbl(i).LINE_DETAIL_INDEX)
       AND lx_price_adj_prcd.EXISTS(p_req_related_lines_tbl(i).RELATED_LINE_DETAIL_INDEX)
    THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_req_related_lines_tbl(i).line_index:'
                            ||p_req_related_lines_tbl(i).line_index,1,'N');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_req_related_lines_tbl(i).line_detail_index:'
                            ||p_req_related_lines_tbl(i).line_detail_index,1,'N');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_req_related_lines_tbl(i).related_line_detail_index:'
                            ||p_req_related_lines_tbl(i).related_line_detail_index,1,'N');
       END IF;
       If l_qte_line_prcd.EXISTS(p_req_related_lines_tbl(i).line_index) Then
          l_price_adj_rltship_rec.QTE_LINE_INDEX :=
                                l_qte_line_prcd(p_req_related_lines_tbl(i).line_index);
       End If;

       IF p_qte_line_tbl.exists((p_req_related_lines_tbl(i).line_index-1)) THEN
          l_price_adj_rltship_rec.quote_line_id :=
                                p_qte_line_tbl((p_req_related_lines_tbl(i).line_index-1)).quote_line_id;
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:p_qte_line_tbl((p_req_related_lines_tbl(i).line_index-1)).quote_line_id: '
                           ||p_qte_line_tbl((p_req_related_lines_tbl(i).line_index-1)).quote_line_id,1,'N');
          END IF;
       END IF;
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Quote Line id '||l_price_adj_rltship_rec.quote_line_id, 1, 'N');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Before  assigning  LINE_DETAIL_INDEX(=>PRICE_ADJ_INDEX) '
                          ||lx_price_adj_prcd(p_req_related_lines_tbl(i).LINE_DETAIL_INDEX), 1, 'N');
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Before  assigning  RELATED_LINE_DETAIL_INDEX(=>RLTD_PRICE_ADJ_INDEX) '
                       ||lx_price_adj_prcd(p_req_related_lines_tbl(i).RELATED_LINE_DETAIL_INDEX), 1, 'N');
       END IF;
       l_price_adj_rltship_rec.PRICE_ADJ_INDEX :=
                        lx_price_adj_prcd(p_req_related_lines_tbl(i).LINE_DETAIL_INDEX);
       l_price_adj_rltship_rec.RLTD_PRICE_ADJ_INDEX :=
                    lx_price_adj_prcd(p_req_related_lines_tbl(i).RELATED_LINE_DETAIL_INDEX);
       l_count1 := x_price_adj_rltship_tbl.count;
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:Count x_price_adj_rltship_tbl.count before assigning the record: '
                                                                                 ||l_count1,1,'N');
       END IF;
       x_price_adj_rltship_tbl(x_price_adj_rltship_tbl.count+1) := l_price_adj_rltship_rec;
    END IF;--p_Req_Related_Lines_Tbl(i).Relationship_Type_Code
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CALLBACK_PVT:**************************NEXT RLTD ADJ********************************',1,'N');
    END IF;
    i := p_req_related_lines_tbl.next(i);
END LOOP;

END Copy_Request_To_Quote;


PROCEDURE Copy_Req_Dtl_To_Price_Adj (
    p_qte_line_index            IN              NUMBER,
    p_qte_line_rec              IN              ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_req_line_dtl_index        IN              NUMBER,
    p_req_line_detail_rec       IN              QP_PREQ_GRP.LINE_DETAIL_REC_TYPE,
    p_req_line_detail_qual_tbl  IN              QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    p_req_line_detail_attr_tbl  IN              QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    px_price_adj_tbl            IN OUT NOCOPY /* file.sql.39 change */            ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    px_price_adj_attr_tbl       IN OUT NOCOPY /* file.sql.39 change */            ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
    px_price_adj_prcd           IN OUT NOCOPY /* file.sql.39 change */            Index_Link_Tbl_Type)
IS
    l_price_adj_rec         ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_attr_rec    ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Rec_Type;
    i                       BINARY_INTEGER;
BEGIN
    l_price_adj_rec.operation_code := 'CREATE';
    l_price_adj_rec.quote_header_id := p_qte_line_rec.quote_header_id;
    l_price_adj_rec.quote_line_id := p_qte_line_rec.quote_line_id;
    l_price_adj_rec.qte_line_index := p_qte_line_index;
    l_price_adj_rec.MODIFIER_HEADER_ID := p_req_line_detail_Rec.list_header_id;
    l_price_adj_rec.MODIFIER_LINE_ID := p_req_line_detail_Rec.list_line_id;
    l_price_adj_rec.MODIFIER_LINE_TYPE_CODE :=
                                  p_req_line_detail_Rec.list_line_type_code;
    l_price_adj_rec.MODIFIED_FROM := NULL;
                               -- p_req_line_detail_Rec.substitution_from;
    l_price_adj_rec.MODIFIED_TO := NULL;
                               -- p_req_line_detail_Rec.substitution_to;
    l_price_adj_rec.OPERAND := p_req_line_detail_Rec.Operand_Value;
    l_price_adj_rec.ARITHMETIC_OPERATOR :=
                                  p_req_line_detail_Rec.Operand_Calculation_Code;
    l_price_adj_rec.AUTOMATIC_FLAG :=
                                  p_req_line_detail_Rec.Automatic_flag;
    l_price_adj_rec.UPDATE_ALLOWABLE_FLAG :=
                                  p_req_line_detail_Rec.Override_flag;
    l_price_adj_rec.UPDATED_FLAG := p_req_line_detail_Rec.UPDATED_FLAG;
    l_price_adj_rec.APPLIED_FLAG := p_req_line_detail_Rec.Applied_Flag;
    l_price_adj_rec.ON_INVOICE_FLAG :=
                                  p_req_line_detail_Rec.Print_On_Invoice_Flag;
    /* Added on 9/27 */
    l_price_adj_rec.CHARGE_TYPE_CODE := p_req_line_detail_Rec.CHARGE_TYPE_CODE;
    l_price_adj_rec.PRICING_PHASE_ID := p_req_line_detail_Rec.Pricing_phase_id;
    /* Added on 10/26 by pmothkur */
    l_price_adj_rec.PRICING_GROUP_SEQUENCE :=
                                 p_req_line_detail_Rec.PRICING_GROUP_SEQUENCE;
    l_price_adj_rec.PRICE_BREAK_TYPE_CODE  :=
                                 p_req_line_detail_Rec.PRICE_BREAK_TYPE_CODE;
    l_price_adj_rec.ADJUSTED_AMOUNT        :=
                                 p_req_line_detail_Rec.ADJUSTMENT_AMOUNT;
    l_price_adj_rec.MODIFIER_LEVEL_CODE    :=
                                 p_req_line_detail_Rec.MODIFIER_LEVEL_CODE;
     /* for this attribute, our record has length of 30, whereas
         pricing attribute has 240 characters. Have to look into this */
--  l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := p_req_line_detail_Rec.SUBSTITUTION_ATTRIBUTE;
    l_price_adj_rec.ACCRUAL_FLAG := p_req_line_detail_Rec.ACCRUAL_FLAG;
    l_price_adj_rec.LIST_LINE_NO := p_req_line_detail_Rec.LIST_LINE_NO;
    l_price_adj_rec.ACCRUAL_CONVERSION_RATE  := p_req_line_detail_Rec.ACCRUAL_CONVERSION_RATE;
    l_price_adj_rec.EXPIRATION_DATE := p_req_line_detail_Rec.EXPIRATION_DATE;
    l_price_adj_rec.CHARGE_SUBTYPE_CODE :=
                                 p_req_line_detail_Rec.CHARGE_SUBTYPE_CODE;
    l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG  :=
                                 p_req_line_detail_Rec.INCLUDE_ON_RETURNS_FLAG;
    l_price_adj_rec.BENEFIT_QTY := p_req_line_detail_Rec.BENEFIT_QTY;
    l_price_adj_rec.BENEFIT_UOM_CODE := p_req_line_detail_Rec.BENEFIT_UOM_CODE;
    l_price_adj_rec.PRORATION_TYPE_CODE := p_req_line_detail_Rec.PRORATION_TYPE_CODE;
    l_price_adj_rec.SOURCE_SYSTEM_CODE  := p_req_line_detail_Rec.SOURCE_SYSTEM_CODE;
    l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE  :=
                                 p_req_line_detail_Rec.REBATE_TRANSACTION_TYPE_CODE;
    l_price_adj_rec.update_allowed  := p_req_line_detail_Rec.OVERRIDE_FLAG;
    l_price_adj_rec.range_break_quantity  := p_req_line_detail_Rec.Line_quantity;
    l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE  := p_req_line_detail_Rec.Calculation_code;
    l_price_adj_rec.change_reason_code  := p_req_line_detail_Rec.change_reason_code;
    l_price_adj_rec.change_reason_text  := p_req_line_detail_Rec.change_reason_text;
    px_price_adj_tbl(px_price_adj_tbl.count+1) := l_price_adj_rec;

    i := p_req_line_detail_qual_tbl.first;
    WHILE i IS NOT NULL LOOP
      IF p_req_line_detail_qual_tbl(i).line_detail_index = p_req_line_dtl_index THEN
         l_price_adj_attr_rec.operation_code := 'CREATE';
         l_price_adj_attr_rec.qte_line_index := p_qte_line_index;
         l_price_adj_attr_rec.PRICE_ADJ_INDEX := px_price_adj_tbl.count;
         l_price_adj_attr_rec.PRICING_CONTEXT := p_req_line_detail_qual_tbl(i).Qualifier_Context;
         l_price_adj_attr_rec.pricing_attribute := p_req_line_detail_qual_tbl(i).Qualifier_Attribute;
         l_price_adj_attr_rec.pricing_attr_value_from :=
                                   p_req_line_detail_qual_tbl(i).Qualifier_Attr_Value_From;
         l_price_adj_attr_rec.pricing_attr_value_To :=
                                     p_req_line_detail_qual_tbl(i).Qualifier_Attr_Value_To;
         l_price_adj_attr_rec.comparison_operator :=
                                    p_req_line_detail_qual_tbl(i).comparison_operator_Code;
         px_price_adj_attr_tbl(px_price_adj_attr_tbl.count+1) := l_price_adj_attr_rec;
         px_price_adj_prcd(i) := px_price_adj_tbl.count;
      END IF;
      i := p_req_line_detail_qual_tbl.next(i);
    END LOOP;

    i := p_req_line_detail_attr_tbl.first;
    WHILE i IS NOT NULL LOOP
      IF p_req_line_detail_attr_tbl(i).line_detail_index = p_req_line_dtl_index THEN
         l_price_adj_attr_rec.operation_code := 'CREATE';
         l_price_adj_attr_rec.qte_line_index := p_qte_line_index;
         l_price_adj_attr_rec.PRICE_ADJ_INDEX := px_price_adj_tbl.count;
         l_price_adj_attr_rec.PRICING_CONTEXT := p_req_line_detail_attr_tbl(i).Pricing_Context;
         l_price_adj_attr_rec.pricing_attribute := p_req_line_detail_attr_tbl(i).Pricing_Attribute;
         l_price_adj_attr_rec.pricing_attr_value_from :=
                                         p_req_line_detail_attr_tbl(i).Pricing_Attr_Value_From;
         l_price_adj_attr_rec.pricing_attr_value_To :=
                                             p_req_line_detail_attr_tbl(i).Pricing_Attr_Value_To;
         px_price_adj_attr_tbl(px_price_adj_attr_tbl.count+1) := l_price_adj_attr_rec;
         px_price_adj_prcd(i) := px_price_adj_attr_tbl.count;
      END IF;
      i := p_req_line_detail_attr_tbl.next(i);
   END LOOP;
END Copy_Req_Dtl_To_Price_Adj;

PROCEDURE Copy_Req_Dtl_To_Price_Adj (
    p_qte_header_rec            IN             ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_req_line_dtl_index        IN             NUMBER,
    p_req_line_detail_rec       IN             QP_PREQ_GRP.LINE_DETAIL_REC_TYPE,
    p_req_line_detail_qual_tbl  IN             QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    p_req_line_detail_attr_tbl  IN             QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    px_price_adj_tbl            IN OUT NOCOPY /* file.sql.39 change */           ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    px_price_adj_attr_tbl       IN OUT NOCOPY /* file.sql.39 change */           ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
    px_price_adj_prcd           IN OUT NOCOPY /* file.sql.39 change */           Index_Link_Tbl_Type)
IS
    l_price_adj_rec         ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_attr_rec    ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Rec_Type;
    i                       BINARY_INTEGER;
BEGIN
    l_price_adj_rec.operation_code := 'CREATE';
    l_price_adj_rec.quote_header_id := p_qte_header_rec.quote_header_id;
    l_price_adj_rec.MODIFIER_HEADER_ID := p_req_line_detail_Rec.list_header_id;
    l_price_adj_rec.MODIFIER_LINE_ID := p_req_line_detail_Rec.list_line_id;
    l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := p_req_line_detail_Rec.list_line_type_code;
    l_price_adj_rec.MODIFIED_FROM := NULL;
    l_price_adj_rec.MODIFIED_TO := NULL;
    l_price_adj_rec.OPERAND := p_req_line_detail_Rec.Operand_Value;
    l_price_adj_rec.ARITHMETIC_OPERATOR := p_req_line_detail_Rec.Operand_Calculation_Code;
    l_price_adj_rec.AUTOMATIC_FLAG := p_req_line_detail_Rec.Automatic_flag;
    l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := p_req_line_detail_Rec.Override_flag;
    l_price_adj_rec.UPDATED_FLAG := p_req_line_detail_Rec.UPDATED_FLAG;
    l_price_adj_rec.APPLIED_FLAG := p_req_line_detail_Rec.Applied_Flag;
    l_price_adj_rec.ON_INVOICE_FLAG := p_req_line_detail_Rec.Print_On_Invoice_Flag;
    /* Added on 9/27 */
    l_price_adj_rec.CHARGE_TYPE_CODE := p_req_line_detail_Rec.CHARGE_TYPE_CODE;
    l_price_adj_rec.PRICING_PHASE_ID := p_req_line_detail_Rec.Pricing_phase_id;
      /* Added on 10/26 by pmothkur */
    l_price_adj_rec.PRICING_GROUP_SEQUENCE :=
                                 p_req_line_detail_Rec.PRICING_GROUP_SEQUENCE;
    l_price_adj_rec.PRICE_BREAK_TYPE_CODE  :=
                                 p_req_line_detail_Rec.PRICE_BREAK_TYPE_CODE;
    l_price_adj_rec.ADJUSTED_AMOUNT        :=
                                 p_req_line_detail_Rec.ADJUSTMENT_AMOUNT;
    l_price_adj_rec.MODIFIER_LEVEL_CODE    :=
                                 p_req_line_detail_Rec.MODIFIER_LEVEL_CODE;
     /* for this attribute, our record has length of 30, whereas
         pricing attribute has 240 characters. Have to look into this */
--  l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := p_req_line_detail_Rec.SUBSTITUTION_ATTRIBUTE;
    l_price_adj_rec.ACCRUAL_FLAG := p_req_line_detail_Rec.ACCRUAL_FLAG;
    l_price_adj_rec.LIST_LINE_NO := p_req_line_detail_Rec.LIST_LINE_NO;
    l_price_adj_rec.ACCRUAL_CONVERSION_RATE  := p_req_line_detail_Rec.ACCRUAL_CONVERSION_RATE;
    l_price_adj_rec.EXPIRATION_DATE := p_req_line_detail_Rec.EXPIRATION_DATE;
    l_price_adj_rec.CHARGE_SUBTYPE_CODE := p_req_line_detail_Rec.CHARGE_SUBTYPE_CODE;
    l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := p_req_line_detail_Rec.INCLUDE_ON_RETURNS_FLAG;
    l_price_adj_rec.BENEFIT_QTY := p_req_line_detail_Rec.BENEFIT_QTY;
    l_price_adj_rec.BENEFIT_UOM_CODE := p_req_line_detail_Rec.BENEFIT_UOM_CODE;
    l_price_adj_rec.PRORATION_TYPE_CODE := p_req_line_detail_Rec.PRORATION_TYPE_CODE;
    l_price_adj_rec.SOURCE_SYSTEM_CODE := p_req_line_detail_Rec.SOURCE_SYSTEM_CODE;
    l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE  := p_req_line_detail_Rec.REBATE_TRANSACTION_TYPE_CODE;
    l_price_adj_rec.update_allowed  := p_req_line_detail_Rec.OVERRIDE_FLAG;
    l_price_adj_rec.change_reason_code  := p_req_line_detail_Rec.change_reason_code;
    l_price_adj_rec.change_reason_text  := p_req_line_detail_Rec.change_reason_text;
    px_price_adj_tbl(px_price_adj_tbl.count+1) := l_price_adj_rec;

    i := p_req_line_detail_qual_tbl.first;
    WHILE i IS NOT NULL LOOP
      IF p_req_line_detail_qual_tbl(i).line_detail_index = p_req_line_dtl_index THEN
         l_price_adj_attr_rec.operation_code := 'CREATE';
         l_price_adj_attr_rec.PRICE_ADJ_INDEX := px_price_adj_tbl.count;
         l_price_adj_attr_rec.PRICING_CONTEXT :=
                        p_req_line_detail_qual_tbl(i).Qualifier_Context;
         l_price_adj_attr_rec.pricing_attribute :=
                      p_req_line_detail_qual_tbl(i).Qualifier_Attribute;
         l_price_adj_attr_rec.pricing_attr_value_from :=
                  p_req_line_detail_qual_tbl(i).Qualifier_Attr_Value_From;
         l_price_adj_attr_rec.pricing_attr_value_To :=
                   p_req_line_detail_qual_tbl(i).Qualifier_Attr_Value_To;
         l_price_adj_attr_rec.comparison_operator :=
                   p_req_line_detail_qual_tbl(i).comparison_operator_Code;
         px_price_adj_attr_tbl(px_price_adj_attr_tbl.count+1) := l_price_adj_attr_rec;
         px_price_adj_prcd(i) := px_price_adj_attr_tbl.count;
      END IF;
      i := p_req_line_detail_qual_tbl.next(i);
   END LOOP;
   i := p_req_line_detail_attr_tbl.first;
   WHILE i IS NOT NULL LOOP
      IF p_req_line_detail_attr_tbl(i).line_detail_index = p_req_line_dtl_index THEN
         l_price_adj_attr_rec.operation_code := 'CREATE';
         l_price_adj_attr_rec.PRICE_ADJ_INDEX := px_price_adj_tbl.count;
         l_price_adj_attr_rec.PRICING_CONTEXT :=
            p_req_line_detail_attr_tbl(i).Pricing_Context;
         l_price_adj_attr_rec.pricing_attribute :=
            p_req_line_detail_attr_tbl(i).Pricing_Attribute;
         l_price_adj_attr_rec.pricing_attr_value_from :=
            p_req_line_detail_attr_tbl(i).Pricing_Attr_Value_From;
         l_price_adj_attr_rec.pricing_attr_value_To :=
            p_req_line_detail_attr_tbl(i).Pricing_Attr_Value_To;
         px_price_adj_attr_tbl(px_price_adj_attr_tbl.count+1) := l_price_adj_attr_rec;
         px_price_adj_prcd(i) := px_price_adj_attr_tbl.count;
      END IF;
      i := p_req_line_detail_attr_tbl.next(i);
    END LOOP;
END Copy_Req_Dtl_To_Price_Adj;


-- Bug 2430068. This following procedure was copied from asoiprcb.pls.115.141 version
-- This is the right version as per vakapoor.
-- Original One was giving no data found.

PROCEDURE Copy_Request_To_Line(
	p_req_line_tbl             IN  QP_PREQ_GRP.LINE_TBL_TYPE,
   	p_req_line_qual            IN  QP_PREQ_GRP.QUAL_TBL_TYPE,
    	p_req_line_attr_tbl        IN  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
	p_req_line_detail_tbl      IN  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
	p_req_line_detail_qual_tbl IN  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
  	p_req_line_detail_attr_tbl IN  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
   	p_req_related_lines_tbl    IN  QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
	p_qte_line_rec		   IN  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
	p_qte_line_dtl_rec	   IN  ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
	x_qte_line_tbl		   OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
	x_qte_line_dtl_tbl	   OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
	x_price_adj_tbl		   OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
	x_price_adj_attr_tbl	   OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
	x_price_adj_rltship_tbl    OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type)
IS
    l_index		NUMBER;
    l_req_line_rec	QP_PREQ_GRP.LINE_REC_TYPE;
    l_req_line_dtl_rec  QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;
    l_qte_line_rec	ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    i			BINARY_INTEGER;
    j			BINARY_INTEGER;
    l_base_price	NUMBER := FND_API.G_MISS_NUM;
    l_price_adj_rltship_rec    ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
    l_qte_line_prcd	Index_Link_Tbl_Type;
    l_price_adj_prcd	Index_Link_Tbl_Type;
    l_message_text      VARCHAR2(2000);
BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line ',1,'Y');
    END IF;
    i := p_req_line_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  in while',1,'Y');
    END IF;
	l_req_line_rec := p_req_line_tbl(i);
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  l_req_line_rec.line_type_code'
				  ||l_req_line_rec.line_type_code,1,'Y');
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  l_req_line_rec.status_code'
				  ||l_req_line_rec.status_code,1,'Y');
            END IF;

	IF l_req_line_rec.line_type_code = 'LINE'  AND
           l_req_line_rec.status_code in ( QP_PREQ_GRP.G_STATUS_UPDATED,
                                          QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                          QP_PREQ_GRP.G_STATUS_UNCHANGED)

	Then
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  in ELSEIF',1,'Y');
            END IF;
	    --IF l_req_line_rec.line_index = 1 THEN
		--l_qte_line_rec := p_qte_line_rec;
	    --END IF;
	    l_qte_line_rec.operation_code := 'UPDATE';
            l_qte_line_rec.line_quote_price :=
			NVL(l_req_line_rec.adjusted_unit_price, l_req_line_rec.unit_price);
            l_qte_line_rec.line_list_price := l_req_line_rec.unit_price ;
 	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line line_list_price '
			  ||l_qte_line_rec.line_list_price,1,'Y');
 	    END IF;
	    l_qte_line_rec.line_adjusted_amount :=
			l_qte_line_rec.line_quote_price-l_qte_line_rec.line_list_price;
	    IF l_qte_line_rec.line_list_price <> 0 THEN
	       l_qte_line_rec.line_adjusted_percent :=
			(l_qte_line_rec.line_adjusted_amount/l_qte_line_rec.line_list_price)*100;
	    END IF;
 	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line before price_list_id ',1,'Y');
 	    END IF;
	    l_qte_line_rec.quantity := l_req_line_rec.priced_quantity ;
	    l_qte_line_rec.uom_code := l_req_line_rec.priced_uom_code ;
	     --l_qte_line_rec.price_list_id := p_req_line_detail_tbl(1).list_header_id ;
 	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line after price_list_id ',1,'Y');
	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line 11 ',1,'Y');
 	    END IF;
            --aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line : Price List Id'||l_qte_line_rec.price_list_id,1,'Y');
 	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:after Copy Req to line ',1,'Y');
 	    END IF;
	    -- handle the percent price
	    IF NVL(l_req_line_rec.percent_price, 0) <> 0 OR
		l_req_line_rec.percent_price <> FND_API.G_MISS_NUM THEN
		j := p_req_related_lines_tbl.first;
		WHILE j IS NOT NULL AND l_base_price = FND_API.G_MISS_NUM LOOP
		    IF p_req_related_lines_tbl(j).line_index = i AND
			p_req_related_lines_tbl(j).relationship_type_code =
				QP_PREQ_GRP.G_RELATED_ITEM_PRICE THEN
			l_base_price := p_req_line_tbl(p_req_related_lines_tbl(j).related_line_index).unit_price;
		    END IF;
		    j :=  p_req_related_lines_tbl.NEXT(j);
		END LOOP;
	        l_qte_line_rec.line_list_price := l_base_price*l_req_line_rec.percent_price;
		l_qte_line_rec.line_quote_price := l_qte_line_rec.line_list_price;
	    END IF;
	    x_qte_line_tbl(x_qte_line_tbl.count+1) := l_qte_line_rec;
	    l_qte_line_prcd(i) := x_qte_line_tbl.count;


        ELSE
  	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  	       aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  In ELSE1',1,'Y');
  	     END IF;
             -- should be later assigned to a pricing error
             l_message_text := substr(l_req_line_rec.status_code || ': '||l_req_line_rec.status_text,1,200);
           /*
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
		  FND_MESSAGE.Set_Token('MSG_TXT', l_message_text, FALSE);
		  FND_MSG_PUB.ADD;
	    END IF;
           */
        END IF;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy Req to line  In ELSE2',1,'Y');
        END IF;
	i :=  p_req_line_tbl.NEXT(i);
    END LOOP;

END Copy_Request_To_Line;


PROCEDURE Update_Quote_Rows(
    P_Qte_Line_Tbl     IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type
            := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
            := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_tbl,
    P_Price_Adj_Tbl       IN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
            := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
            := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl     IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
            := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl)
IS
    G_USER_ID                    NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                   NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    l_Qte_Line_rec               ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_price_adj_tbl              ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                                   := P_Price_Adj_Tbl;
    l_Price_Adj_Attr_Tbl         ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                                   := P_Price_Adj_Attr_Tbl;
    l_Price_Adj_Rltship_Tbl      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                                   := P_Price_Adj_Rltship_Tbl;
    l_price_adj_rec              ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_Price_Adj_Attr_rec         ASO_QUOTE_PUB.Price_Adj_Attr_Rec_Type ;
    l_Price_Adj_Rltship_rec      ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
    l_quote_line_id              NUMBER;
    l_price_adjustment_id        NUMBER;
BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:In  Update_Quote_Rows', 1, 'Y');
    END IF;
    FOR i IN 1..P_Qte_Line_Tbl.count LOOP
      l_qte_line_rec := p_qte_line_tbl(i);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_qte_line_rec.operation_code in Update Quote Rows is '
                           ||l_qte_line_rec.operation_code,1,'N');
      END IF;
      IF l_qte_line_rec.operation_code = 'UPDATE' THEN
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before  ASO_QUOTE_LINES_PKG.Update_Row QUOTE_HEADER_ID'
                              ||l_qte_line_rec.QUOTE_HEADER_ID, 1, 'N');
         END IF;
         ASO_QUOTE_LINES_PKG.Update_Row(
             p_QUOTE_LINE_ID              => l_qte_line_rec.QUOTE_LINE_ID,
             p_CREATION_DATE              => SYSDATE,
             p_CREATED_BY                 => G_USER_ID,
             p_LAST_UPDATE_DATE           => SYSDATE,
             p_LAST_UPDATED_BY            => G_USER_ID,
             p_LAST_UPDATE_LOGIN          => G_LOGIN_ID,
             p_REQUEST_ID                 => l_qte_line_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID     => l_qte_line_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID                 => l_qte_line_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE        => l_qte_line_rec.PROGRAM_UPDATE_DATE,
             p_QUOTE_HEADER_ID            => l_qte_line_rec.QUOTE_HEADER_ID,
             p_ORG_ID                     => l_qte_line_rec.ORG_ID        ,
             p_LINE_CATEGORY_CODE         => l_qte_line_rec.LINE_CATEGORY_CODE ,
             p_ITEM_TYPE_CODE             => l_qte_line_rec.ITEM_TYPE_CODE,
             p_LINE_NUMBER                => l_qte_line_rec.LINE_NUMBER,
             p_START_DATE_ACTIVE          => l_qte_line_rec.START_DATE_ACTIVE,
             p_END_DATE_ACTIVE            => l_qte_line_rec.END_DATE_ACTIVE,
             p_ORDER_LINE_TYPE_ID         => l_qte_line_rec.ORDER_LINE_TYPE_ID,
             p_INVOICE_TO_PARTY_SITE_ID   => l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID,
             p_INVOICE_TO_PARTY_ID        => l_qte_line_rec.INVOICE_TO_PARTY_ID,
             p_INVOICE_TO_CUST_ACCOUNT_ID => l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID,
             p_ORGANIZATION_ID            => l_qte_line_rec.ORGANIZATION_ID,
             p_INVENTORY_ITEM_ID          => l_qte_line_rec.INVENTORY_ITEM_ID ,
             p_QUANTITY                   => l_qte_line_rec.QUANTITY,
             p_UOM_CODE                   => l_qte_line_rec.UOM_CODE,
             p_MARKETING_SOURCE_CODE_ID   => l_qte_line_rec.marketing_source_code_id,
             p_PRICE_LIST_ID              => l_qte_line_rec.PRICE_LIST_ID,
             p_PRICE_LIST_LINE_ID         => l_qte_line_rec.PRICE_LIST_LINE_ID,
             p_CURRENCY_CODE              => l_qte_line_rec.CURRENCY_CODE,
             p_LINE_LIST_PRICE            => l_qte_line_rec.LINE_LIST_PRICE,
             p_LINE_ADJUSTED_AMOUNT       => l_qte_line_rec.LINE_ADJUSTED_AMOUNT,
             p_LINE_ADJUSTED_PERCENT      => l_qte_line_rec.LINE_ADJUSTED_PERCENT,
             p_LINE_QUOTE_PRICE           => l_qte_line_rec.LINE_QUOTE_PRICE,
             p_RELATED_ITEM_ID            => l_qte_line_rec.RELATED_ITEM_ID,
             p_ITEM_RELATIONSHIP_TYPE     => l_qte_line_rec.ITEM_RELATIONSHIP_TYPE,
             p_ACCOUNTING_RULE_ID         => l_qte_line_rec.ACCOUNTING_RULE_ID,
             p_INVOICING_RULE_ID          => l_qte_line_rec.INVOICING_RULE_ID,
             p_SPLIT_SHIPMENT_FLAG        => l_qte_line_rec.SPLIT_SHIPMENT_FLAG,
             p_BACKORDER_FLAG             => l_qte_line_rec.BACKORDER_FLAG,
             p_minisite_id                => l_qte_line_rec.minisite_id,
             p_section_id                 => l_qte_line_rec.section_id,
             p_PRICED_PRICE_LIST_ID       => l_qte_line_rec.PRICED_PRICE_LIST_ID,
             p_COMMITMENT_ID              => l_qte_line_rec.COMMITMENT_ID,
             p_AGREEMENT_ID               => l_qte_line_rec.AGREEMENT_ID,
             p_ATTRIBUTE_CATEGORY         => l_qte_line_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1                 => l_qte_line_rec.ATTRIBUTE1,
             p_ATTRIBUTE2                 => l_qte_line_rec.ATTRIBUTE2,
             p_ATTRIBUTE3                 => l_qte_line_rec.ATTRIBUTE3,
             p_ATTRIBUTE4                 => l_qte_line_rec.ATTRIBUTE4,
             p_ATTRIBUTE5                 => l_qte_line_rec.ATTRIBUTE5,
             p_ATTRIBUTE6                 => l_qte_line_rec.ATTRIBUTE6,
             p_ATTRIBUTE7                 => l_qte_line_rec.ATTRIBUTE7,
             p_ATTRIBUTE8                 => l_qte_line_rec.ATTRIBUTE8,
             p_ATTRIBUTE9                 => l_qte_line_rec.ATTRIBUTE9,
             p_ATTRIBUTE10                => l_qte_line_rec.ATTRIBUTE10,
             p_ATTRIBUTE11                => l_qte_line_rec.ATTRIBUTE11,
             p_ATTRIBUTE12                => l_qte_line_rec.ATTRIBUTE12,
             p_ATTRIBUTE13                => l_qte_line_rec.ATTRIBUTE13,
             p_ATTRIBUTE14                => l_qte_line_rec.ATTRIBUTE14,
             p_ATTRIBUTE15                => l_qte_line_rec.ATTRIBUTE15,
             p_ATTRIBUTE16                  => l_qte_line_rec.ATTRIBUTE16,
             p_ATTRIBUTE17                  => l_qte_line_rec.ATTRIBUTE17,
             p_ATTRIBUTE18                  => l_qte_line_rec.ATTRIBUTE18,
             p_ATTRIBUTE19                  => l_qte_line_rec.ATTRIBUTE19,
             p_ATTRIBUTE20                  => l_qte_line_rec.ATTRIBUTE20,
		   p_DISPLAY_ARITHMETIC_OPERATOR => l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR,
		   p_line_type_source_flag       => l_qte_line_rec.line_type_source_flag,
		   p_SERVICE_ITEM_FLAG           => l_qte_line_rec.SERVICE_ITEM_FLAG,
		   p_SERVICEABLE_PRODUCT_FLAG    => l_qte_line_rec.SERVICEABLE_PRODUCT_FLAG,
		   p_INVOICE_TO_CUST_PARTY_ID    => l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,
		   p_SELLING_PRICE_CHANGE        => l_qte_line_rec.SELLING_PRICE_CHANGE,
		   p_RECALCULATE_FLAG            => l_qte_line_rec.RECALCULATE_FLAG,
		   p_pricing_line_type_indicator => l_qte_line_rec.pricing_line_type_indicator,
             p_END_CUSTOMER_PARTY_ID         =>  l_qte_line_rec.END_CUSTOMER_PARTY_ID,
             p_END_CUSTOMER_CUST_PARTY_ID    =>  l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID,
             p_END_CUSTOMER_PARTY_SITE_ID    =>  l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID,
             p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		   p_OBJECT_VERSION_NUMBER       => l_qte_line_rec.OBJECT_VERSION_NUMBER,
             p_CHARGE_PERIODICITY_CODE     => l_qte_line_rec.CHARGE_PERIODICITY_CODE, -- Recurring charges Change
             p_ship_model_complete_flag      => l_qte_line_rec.ship_model_complete_flag,
             p_LINE_PAYNOW_CHARGES => l_qte_line_rec.LINE_PAYNOW_CHARGES,
             p_LINE_PAYNOW_TAX => l_qte_line_rec.LINE_PAYNOW_TAX,
             p_LINE_PAYNOW_SUBTOTAL => l_qte_line_rec.LINE_PAYNOW_SUBTOTAL,
		   p_PRICING_QUANTITY_UOM => l_qte_line_rec.PRICING_QUANTITY_UOM,
		   p_PRICING_QUANTITY => l_qte_line_rec.PRICING_QUANTITY,
		   p_CONFIG_MODEL_TYPE => l_qte_line_rec.CONFIG_MODEL_TYPE ,
		       -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   l_qte_line_rec.TRX_BUSINESS_CATEGORY
	     --ER 16531247
    ,P_ORDERED_ITEM_ID   => l_qte_line_rec.ORDERED_ITEM_ID
,P_ITEM_IDENTIFIER_TYPE => l_qte_line_rec.ITEM_IDENTIFIER_TYPE
,P_ORDERED_ITEM   => l_qte_line_rec.ORDERED_ITEM
 -- ER 21158830
,P_LINE_UNIT_COST =>  l_qte_line_rec.LINE_UNIT_COST
,P_LINE_MARGIN_AMOUNT =>  l_qte_line_rec.LINE_MARGIN_AMOUNT
,P_LINE_MARGIN_PERCENT =>  l_qte_line_rec.LINE_MARGIN_PERCENT
,P_QUANTITY_UOM_CHANGE =>  l_qte_line_rec.QUANTITY_UOM_CHANGE          -- added for Bug 22582573
		  );

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:After  ASO_QUOTE_LINES_PKG.Update_Row with UPDATE', 1, 'N');
          END IF;

          FOR j IN 1..l_Price_Adj_Tbl.count LOOP
            IF l_Price_Adj_Tbl(j).qte_line_index = i THEN
               l_Price_Adj_Tbl(j).quote_line_id := l_qte_line_rec.QUOTE_LINE_ID;
            END IF;
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:Update The quote line in l_Price_Adj_Tbl is '
                                 ||l_Price_Adj_Tbl(j).quote_line_id,1,'N');
            END IF;
          END LOOP;
          FOR j IN 1..l_Price_Adj_Rltship_Tbl.count LOOP
            IF l_Price_Adj_Rltship_Tbl(j).qte_line_index = i THEN
               l_Price_Adj_Rltship_Tbl(j).quote_line_id := l_qte_line_rec.QUOTE_LINE_ID;
            END IF;
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:Update The quote line in l_Price_Adj_Rltship_Tbl is '
                                 ||l_Price_Adj_Rltship_Tbl(j).quote_line_id,1,'N');
            END IF;
          END LOOP;
       ELSIF l_qte_line_rec.operation_code = 'CREATE' THEN
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before  ASO_QUOTE_LINES_PKG.Insert_Row QUOTE_HEADER_ID'
                                   ||l_qte_line_rec.QUOTE_HEADER_ID, 1, 'N');
            END IF;
            ASO_QUOTE_LINES_PKG.Insert_Row(
                px_QUOTE_LINE_ID               => l_QUOTE_LINE_ID,
                p_CREATION_DATE                => SYSDATE,
                p_CREATED_BY                   => G_USER_ID,
                p_LAST_UPDATE_DATE             => SYSDATE,
                p_LAST_UPDATED_BY              => G_USER_ID,
                p_LAST_UPDATE_LOGIN            => G_LOGIN_ID,
                p_REQUEST_ID                   => l_qte_line_rec.REQUEST_ID,
                p_PROGRAM_APPLICATION_ID       => l_qte_line_rec.PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID                   => l_qte_line_rec.PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE          => l_qte_line_rec.PROGRAM_UPDATE_DATE,
                p_QUOTE_HEADER_ID              => l_qte_line_rec.QUOTE_HEADER_ID,
                p_ORG_ID                       => l_qte_line_rec.ORG_ID,
                p_LINE_CATEGORY_CODE           => l_qte_line_rec.LINE_CATEGORY_CODE,
                p_ITEM_TYPE_CODE               => l_qte_line_rec.ITEM_TYPE_CODE,
                p_LINE_NUMBER                  => l_qte_line_rec.LINE_NUMBER,
                p_START_DATE_ACTIVE            => l_qte_line_rec.START_DATE_ACTIVE,
                p_END_DATE_ACTIVE              => l_qte_line_rec.END_DATE_ACTIVE,
                p_ORDER_LINE_TYPE_ID           => l_qte_line_rec.ORDER_LINE_TYPE_ID,
                p_INVOICE_TO_PARTY_SITE_ID     => l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID,
                p_INVOICE_TO_PARTY_ID          => l_qte_line_rec.INVOICE_TO_PARTY_ID,
                p_INVOICE_TO_CUST_ACCOUNT_ID   => l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID,
                p_ORGANIZATION_ID              => l_qte_line_rec.ORGANIZATION_ID,
                p_INVENTORY_ITEM_ID            => l_qte_line_rec.INVENTORY_ITEM_ID,
                p_QUANTITY                     => l_qte_line_rec.QUANTITY,
                p_UOM_CODE                     => l_qte_line_rec.UOM_CODE,
                p_MARKETING_SOURCE_CODE_ID     => l_qte_line_rec.marketing_source_code_id,
                p_PRICE_LIST_ID                => l_qte_line_rec.PRICE_LIST_ID,
                p_PRICE_LIST_LINE_ID           => l_qte_line_rec.PRICE_LIST_LINE_ID,
                p_CURRENCY_CODE                => l_qte_line_rec.CURRENCY_CODE,
                p_LINE_LIST_PRICE              => l_qte_line_rec.LINE_LIST_PRICE,
                p_LINE_ADJUSTED_AMOUNT         => l_qte_line_rec.LINE_ADJUSTED_AMOUNT,
                p_LINE_ADJUSTED_PERCENT        => l_qte_line_rec.LINE_ADJUSTED_PERCENT,
                p_LINE_QUOTE_PRICE             => l_qte_line_rec.LINE_QUOTE_PRICE,
                p_RELATED_ITEM_ID              => l_qte_line_rec.RELATED_ITEM_ID,
                p_ITEM_RELATIONSHIP_TYPE       => l_qte_line_rec.ITEM_RELATIONSHIP_TYPE,
                p_ACCOUNTING_RULE_ID           => l_qte_line_rec.ACCOUNTING_RULE_ID,
                p_INVOICING_RULE_ID            => l_qte_line_rec.INVOICING_RULE_ID,
                p_SPLIT_SHIPMENT_FLAG          => l_qte_line_rec.SPLIT_SHIPMENT_FLAG,
                p_BACKORDER_FLAG               => l_qte_line_rec.BACKORDER_FLAG,
                p_minisite_id                  => l_qte_line_rec.minisite_id,
                p_section_id                   => l_qte_line_rec.section_id,
                p_PRICED_PRICE_LIST_ID         => l_qte_line_rec.PRICED_PRICE_LIST_ID,
                p_COMMITMENT_ID                => l_qte_line_rec.COMMITMENT_ID,
                p_AGREEMENT_ID                 => l_qte_line_rec.AGREEMENT_ID,
                p_ATTRIBUTE_CATEGORY           => l_qte_line_rec.ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1                   => l_qte_line_rec.ATTRIBUTE1,
                p_ATTRIBUTE2                   => l_qte_line_rec.ATTRIBUTE2,
                p_ATTRIBUTE3                   => l_qte_line_rec.ATTRIBUTE3,
                p_ATTRIBUTE4                   => l_qte_line_rec.ATTRIBUTE4,
                p_ATTRIBUTE5                   => l_qte_line_rec.ATTRIBUTE5,
                p_ATTRIBUTE6                   => l_qte_line_rec.ATTRIBUTE6,
                p_ATTRIBUTE7                   => l_qte_line_rec.ATTRIBUTE7,
                p_ATTRIBUTE8                   => l_qte_line_rec.ATTRIBUTE8,
                p_ATTRIBUTE9                   => l_qte_line_rec.ATTRIBUTE9,
                p_ATTRIBUTE10                  => l_qte_line_rec.ATTRIBUTE10,
                p_ATTRIBUTE11                  => l_qte_line_rec.ATTRIBUTE11,
                p_ATTRIBUTE12                  => l_qte_line_rec.ATTRIBUTE12,
                p_ATTRIBUTE13                  => l_qte_line_rec.ATTRIBUTE13,
                p_ATTRIBUTE14                  => l_qte_line_rec.ATTRIBUTE14,
                p_ATTRIBUTE15                  => l_qte_line_rec.ATTRIBUTE15,
                p_ATTRIBUTE16                  => l_qte_line_rec.ATTRIBUTE16,
			 p_ATTRIBUTE17                  => l_qte_line_rec.ATTRIBUTE17,
			 p_ATTRIBUTE18                  => l_qte_line_rec.ATTRIBUTE18,
			 p_ATTRIBUTE19                  => l_qte_line_rec.ATTRIBUTE19,
			 p_ATTRIBUTE20                  => l_qte_line_rec.ATTRIBUTE20,
			 p_DISPLAY_ARITHMETIC_OPERATOR  => l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR,
                p_line_type_source_flag        => l_qte_line_rec.line_type_source_flag,
                p_SERVICE_ITEM_FLAG            => l_qte_line_rec.SERVICE_ITEM_FLAG,
                p_SERVICEABLE_PRODUCT_FLAG     => l_qte_line_rec.SERVICEABLE_PRODUCT_FLAG,
		   p_INVOICE_TO_CUST_PARTY_ID    => l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,
		   p_SELLING_PRICE_CHANGE        => l_qte_line_rec.SELLING_PRICE_CHANGE,
		   p_RECALCULATE_FLAG            => l_qte_line_rec.RECALCULATE_FLAG,
		   p_pricing_line_type_indicator            => l_qte_line_rec.pricing_line_type_indicator,
             p_END_CUSTOMER_PARTY_ID         =>  l_qte_line_rec.END_CUSTOMER_PARTY_ID,
             p_END_CUSTOMER_CUST_PARTY_ID    =>  l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID,
             p_END_CUSTOMER_PARTY_SITE_ID    =>  l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID,
             p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		   p_OBJECT_VERSION_NUMBER       => l_qte_line_rec.OBJECT_VERSION_NUMBER,
               p_CHARGE_PERIODICITY_CODE     => l_qte_line_rec.CHARGE_PERIODICITY_CODE, -- Recurring charges Change
             p_ship_model_complete_flag      => l_qte_line_rec.ship_model_complete_flag,
             p_LINE_PAYNOW_CHARGES => l_qte_line_rec.LINE_PAYNOW_CHARGES,
             p_LINE_PAYNOW_TAX => l_qte_line_rec.LINE_PAYNOW_TAX,
             p_LINE_PAYNOW_SUBTOTAL => l_qte_line_rec.LINE_PAYNOW_SUBTOTAL,
		   p_PRICING_QUANTITY_UOM => l_qte_line_rec.PRICING_QUANTITY_UOM,
		   p_PRICING_QUANTITY => l_qte_line_rec.PRICING_QUANTITY,
             p_CONFIG_MODEL_TYPE => l_qte_line_rec.CONFIG_MODEL_TYPE,
	              -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   l_qte_line_rec.TRX_BUSINESS_CATEGORY
	  --ER 16531247
    ,P_ORDERED_ITEM_ID   => l_qte_line_rec.ORDERED_ITEM_ID
,P_ITEM_IDENTIFIER_TYPE => l_qte_line_rec.ITEM_IDENTIFIER_TYPE
,P_ORDERED_ITEM   => l_qte_line_rec.ORDERED_ITEM
 -- ER 21158830
,P_LINE_UNIT_COST =>  l_qte_line_rec.LINE_UNIT_COST
,P_LINE_MARGIN_AMOUNT =>  l_qte_line_rec.LINE_MARGIN_AMOUNT
,P_LINE_MARGIN_PERCENT =>  l_qte_line_rec.LINE_MARGIN_PERCENT
,P_QUANTITY_UOM_CHANGE =>  l_qte_line_rec.QUANTITY_UOM_CHANGE    -- added for Bug 22237877
             );

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:After  ASO_QUOTE_LINES_PKG.Insert_row with CREATE', 1, 'N');
            END IF;

            FOR j IN 1..l_Price_Adj_Tbl.count LOOP
                IF l_Price_Adj_Tbl(j).qte_line_index = i THEN
                   l_Price_Adj_Tbl(j).quote_line_id := l_QUOTE_LINE_ID;
                END IF;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_CORE_PVT:The quote line in l_Price_Adj_Tbl is '
                                     ||l_Price_Adj_Tbl(j).quote_line_id,1,'N');
                END IF;
            END LOOP;
            FOR j IN 1..l_Price_Adj_Rltship_Tbl.count LOOP
                IF l_Price_Adj_Rltship_Tbl(j).qte_line_index = i THEN
                   l_Price_Adj_Rltship_Tbl(j).quote_line_id := l_QUOTE_LINE_ID;
                END IF;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_CORE_PVT:The quote line in l_Price_Adj_Rltship_Tbl is '
                                     ||l_Price_Adj_Rltship_Tbl(j).quote_line_id,1,'N');
                END IF;
            END LOOP;
       END IF;

    END LOOP;

    FOR i IN 1..l_Price_Adj_Tbl.count LOOP
        l_price_adj_rec := l_Price_Adj_Tbl(i);
        l_PRICE_ADJUSTMENT_ID := NULL;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before  ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row', 1, 'N');
        END IF;
        ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row(
                px_PRICE_ADJUSTMENT_ID             => l_PRICE_ADJUSTMENT_ID,
                p_CREATION_DATE                    => SYSDATE,
                p_CREATED_BY                       => G_USER_ID,
                p_LAST_UPDATE_DATE                 => SYSDATE,
                p_LAST_UPDATED_BY                  => G_USER_ID,
                p_LAST_UPDATE_LOGIN                => G_LOGIN_ID,
                p_PROGRAM_APPLICATION_ID           => l_price_adj_rec.PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID                       => l_price_adj_rec.PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE              => l_price_adj_rec.PROGRAM_UPDATE_DATE,
                p_REQUEST_ID                       => l_price_adj_rec.REQUEST_ID,
                p_QUOTE_HEADER_ID                  => l_price_adj_rec.QUOTE_HEADER_ID,
                p_QUOTE_LINE_ID                    => l_price_adj_rec.QUOTE_LINE_ID,
                p_MODIFIER_HEADER_ID               => l_price_adj_rec.MODIFIER_HEADER_ID,
                p_MODIFIER_LINE_ID                 => l_price_adj_rec.MODIFIER_LINE_ID,
                p_MODIFIER_LINE_TYPE_CODE          => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
                p_MODIFIER_MECHANISM_TYPE_CODE     => l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
                p_MODIFIED_FROM                    => l_price_adj_rec.MODIFIED_FROM,
                p_MODIFIED_TO                      => l_price_adj_rec.MODIFIED_TO,
                p_OPERAND                          => l_price_adj_rec.OPERAND,
                p_ARITHMETIC_OPERATOR              => l_price_adj_rec.ARITHMETIC_OPERATOR,
                p_AUTOMATIC_FLAG                   => l_price_adj_rec.AUTOMATIC_FLAG,
                p_UPDATE_ALLOWABLE_FLAG            => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
                p_UPDATED_FLAG                     => l_price_adj_rec.UPDATED_FLAG,
                p_APPLIED_FLAG                     => l_price_adj_rec.APPLIED_FLAG,
                p_ON_INVOICE_FLAG                  => l_price_adj_rec.ON_INVOICE_FLAG,
                p_PRICING_PHASE_ID                 => l_price_adj_rec.PRICING_PHASE_ID,
                p_ATTRIBUTE_CATEGORY               => l_price_adj_rec.ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1                       => l_price_adj_rec.ATTRIBUTE1,
                p_ATTRIBUTE2                       => l_price_adj_rec.ATTRIBUTE2,
                p_ATTRIBUTE3                       => l_price_adj_rec.ATTRIBUTE3,
                p_ATTRIBUTE4                       => l_price_adj_rec.ATTRIBUTE4,
                p_ATTRIBUTE5                       => l_price_adj_rec.ATTRIBUTE5,
                p_ATTRIBUTE6                       => l_price_adj_rec.ATTRIBUTE6,
                p_ATTRIBUTE7                       => l_price_adj_rec.ATTRIBUTE7,
                p_ATTRIBUTE8                       => l_price_adj_rec.ATTRIBUTE8,
                p_ATTRIBUTE9                       => l_price_adj_rec.ATTRIBUTE9,
                p_ATTRIBUTE10                      => l_price_adj_rec.ATTRIBUTE10,
                p_ATTRIBUTE11                      => l_price_adj_rec.ATTRIBUTE11,
                p_ATTRIBUTE12                      => l_price_adj_rec.ATTRIBUTE12,
                p_ATTRIBUTE13                      => l_price_adj_rec.ATTRIBUTE13,
                p_ATTRIBUTE14                      => l_price_adj_rec.ATTRIBUTE14,
                p_ATTRIBUTE15                      => l_price_adj_rec.ATTRIBUTE15,
                p_ATTRIBUTE16                      => l_price_adj_rec.ATTRIBUTE16,
                p_ATTRIBUTE17                      => l_price_adj_rec.ATTRIBUTE17,
                p_ATTRIBUTE18                      => l_price_adj_rec.ATTRIBUTE18,
                p_ATTRIBUTE19                      => l_price_adj_rec.ATTRIBUTE19,
                p_ATTRIBUTE20                      => l_price_adj_rec.ATTRIBUTE20,

			 p_ORIG_SYS_DISCOUNT_REF            => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF,
                p_CHANGE_SEQUENCE                  => l_price_adj_rec.CHANGE_SEQUENCE,
                p_UPDATE_ALLOWED                   => l_price_adj_rec.UPDATE_ALLOWED,
                p_CHANGE_REASON_CODE               => l_price_adj_rec.CHANGE_REASON_CODE,
                p_CHANGE_REASON_TEXT               => l_price_adj_rec.CHANGE_REASON_TEXT,
                p_COST_ID                          => l_price_adj_rec.COST_ID,
                p_TAX_CODE                         => l_price_adj_rec.TAX_CODE,
                p_TAX_EXEMPT_FLAG                  => l_price_adj_rec.TAX_EXEMPT_FLAG,
                p_TAX_EXEMPT_NUMBER                => l_price_adj_rec.TAX_EXEMPT_NUMBER,
                p_TAX_EXEMPT_REASON_CODE           => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
                p_PARENT_ADJUSTMENT_ID             => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
                p_INVOICED_FLAG                    => l_price_adj_rec.INVOICED_FLAG,
                p_ESTIMATED_FLAG                   => l_price_adj_rec.ESTIMATED_FLAG,
                p_INC_IN_SALES_PERFORMANCE         => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
                p_SPLIT_ACTION_CODE                => l_price_adj_rec.SPLIT_ACTION_CODE,
                p_ADJUSTED_AMOUNT                  => l_price_adj_rec.ADJUSTED_AMOUNT,
                p_CHARGE_TYPE_CODE                 => l_price_adj_rec.CHARGE_TYPE_CODE,
                p_CHARGE_SUBTYPE_CODE              => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
                p_RANGE_BREAK_QUANTITY             => l_price_adj_rec.RANGE_BREAK_QUANTITY,
                p_ACCRUAL_CONVERSION_RATE          => l_price_adj_rec.ACCRUAL_CONVERSION_RATE,
                p_PRICING_GROUP_SEQUENCE           => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
                p_ACCRUAL_FLAG                     => l_price_adj_rec.ACCRUAL_FLAG,
                p_LIST_LINE_NO                     => l_price_adj_rec.LIST_LINE_NO,
                p_SOURCE_SYSTEM_CODE               => l_price_adj_rec.SOURCE_SYSTEM_CODE,
                p_BENEFIT_QTY                      => l_price_adj_rec.BENEFIT_QTY,
                p_BENEFIT_UOM_CODE                 => l_price_adj_rec.BENEFIT_UOM_CODE,
                p_PRINT_ON_INVOICE_FLAG            => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
                p_EXPIRATION_DATE                  => l_price_adj_rec.EXPIRATION_DATE,
                p_REBATE_TRANSACTION_TYPE_CODE     => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
                p_REBATE_TRANSACTION_REFERENCE     => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
                p_REBATE_PAYMENT_SYSTEM_CODE       => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
                p_REDEEMED_DATE                    => l_price_adj_rec.REDEEMED_DATE,
                p_REDEEMED_FLAG                    => l_price_adj_rec.REDEEMED_FLAG,
                p_MODIFIER_LEVEL_CODE              => l_price_adj_rec.MODIFIER_LEVEL_CODE,
                p_PRICE_BREAK_TYPE_CODE            => l_price_adj_rec.PRICE_BREAK_TYPE_CODE,
                p_SUBSTITUTION_ATTRIBUTE           => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
                p_PRORATION_TYPE_CODE              => l_price_adj_rec.PRORATION_TYPE_CODE,
                p_INCLUDE_ON_RETURNS_FLAG          => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
                p_CREDIT_OR_CHARGE_FLAG            => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
			 p_OPERAND_PER_PQTY                 => l_price_adj_rec.OPERAND_PER_PQTY,
			 p_ADJUSTED_AMOUNT_PER_PQTY         => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
			 p_OBJECT_VERSION_NUMBER            => l_price_adj_rec.OBJECT_VERSION_NUMBER
            );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:After ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row PRICE_ADJUSTMENT_ID'
                             ||l_PRICE_ADJUSTMENT_ID, 1, 'N');
        END IF;
        FOR j in 1..l_price_adj_attr_tbl.count LOOP
            IF l_price_adj_attr_tbl(j).price_adj_index = i THEN
               l_price_adj_attr_tbl(j).price_adjustment_id := l_PRICE_ADJUSTMENT_ID;
            END IF;
        END LOOP;

        FOR j IN 1..l_price_adj_rltship_tbl.count LOOP
            IF l_price_adj_rltship_tbl(j).price_adj_index = i THEN
                l_price_adj_rltship_tbl(j).price_adjustment_id := l_price_adjustment_id;
            END IF;
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:After price_adj_index Loop l_price_adj_rltship_tbl', 1, 'N');
            END IF;
            IF l_price_adj_rltship_tbl(j).rltd_price_adj_index = i THEN
                    l_price_adj_rltship_tbl(j).rltd_price_adj_id := l_price_adjustment_id;
            END IF;
       END LOOP;
   END LOOP;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:xxxxxxxxxxStart inserting into ASO_PRICE_ADJ_ATTRIBSxxxxxxx', 1, 'N');
   END IF;
   FOR i in 1..l_price_adj_attr_tbl.count LOOP
       l_price_adj_attr_rec := l_price_adj_attr_tbl(i);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before  ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row', 1, 'N');
       END IF;
       ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row(
            px_PRICE_ADJ_ATTRIB_ID          => l_price_adj_attr_rec.PRICE_ADJ_ATTRIB_ID,
            p_CREATION_DATE                 => SYSDATE,
            p_CREATED_BY                    => G_USER_ID,
            p_LAST_UPDATE_DATE              => SYSDATE,
            p_LAST_UPDATED_BY               => G_USER_ID,
            p_LAST_UPDATE_LOGIN             => G_LOGIN_ID,
            p_PROGRAM_APPLICATION_ID        =>l_price_adj_attr_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID                    => l_price_adj_attr_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE           => l_price_adj_attr_rec.PROGRAM_UPDATE_DATE,
            p_REQUEST_ID                    => l_price_adj_attr_rec.REQUEST_ID,
            p_PRICE_ADJUSTMENT_ID           => l_price_adj_attr_rec.PRICE_ADJUSTMENT_ID,
            p_PRICING_CONTEXT               => l_price_adj_attr_rec.PRICING_CONTEXT,
            p_PRICING_ATTRIBUTE             => l_price_adj_attr_rec.PRICING_ATTRIBUTE,
            p_PRICING_ATTR_VALUE_FROM       => l_price_adj_attr_rec.PRICING_ATTR_VALUE_FROM,
            p_PRICING_ATTR_VALUE_TO         => l_price_adj_attr_rec.PRICING_ATTR_VALUE_TO,
            p_COMPARISON_OPERATOR           => l_price_adj_attr_rec.COMPARISON_OPERATOR,
            p_FLEX_TITLE                    => l_price_adj_attr_rec.FLEX_TITLE,
		  p_OBJECT_VERSION_NUMBER         => l_price_adj_attr_rec.OBJECT_VERSION_NUMBER);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:After  ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row', 1, 'N');
       END IF;
   END LOOP;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:xxxxxxxxxxFinish inserting into ASO_PRICE_ADJ_ATTRIBSxxxxxx', 1, 'N');
   END IF;

   FOR i IN 1..l_price_adj_rltship_tbl.count LOOP
       l_price_adj_rltship_rec := l_price_adj_rltship_tbl(i);
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before  ASO_PRICE_RLTSHIPS_PKG.Insert_Row', 1, 'N');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:The quote line id is '
                                                 ||l_price_adj_rltship_rec.quote_line_id, 1, 'N');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:The price adjustment id is '
                                                 ||l_price_adj_rltship_rec.price_adjustment_id,1,'N');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:The rltd price adj id is '
                                                 ||l_price_adj_rltship_rec.rltd_price_adj_id,1,'N');
       END IF;
       ASO_PRICE_RLTSHIPS_PKG.Insert_Row(
            px_ADJ_RELATIONSHIP_ID       => l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID,
            p_creation_date              => sysdate,
            p_CREATED_BY                 => G_USER_ID,
            p_LAST_UPDATE_DATE           => sysdate,
            p_LAST_UPDATED_BY            => G_USER_ID,
            p_LAST_UPDATE_LOGIN          => G_USER_ID,
            p_PROGRAM_APPLICATION_ID     => l_price_adj_rltship_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID                 => l_price_adj_rltship_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE        => l_price_adj_rltship_rec.PROGRAM_UPDATE_DATE,
            p_REQUEST_ID                 => l_price_adj_rltship_rec.REQUEST_ID,
            p_QUOTE_LINE_ID              => l_price_adj_rltship_rec.quote_line_id,
            p_PRICE_ADJUSTMENT_ID        => l_price_adj_rltship_rec.price_adjustment_id,
            p_RLTD_PRICE_ADJ_ID          => l_price_adj_rltship_rec.rltd_price_adj_id,
	    p_quote_shipment_id => l_price_adj_rltship_rec.quote_shipment_id,
	    p_OBJECT_VERSION_NUMBER         => l_price_adj_rltship_rec.OBJECT_VERSION_NUMBER
        );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:After  ASO_PRICE_RLTSHIPS_PKG.Insert_Row', 1, 'N');
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:The adj relationship id  is '
                                                ||l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID,1,'N');
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII', 1, 'N');
      END IF;
  END LOOP;
END Update_Quote_Rows;

End ASO_PRICING_CALLBACK_PVT;

/
