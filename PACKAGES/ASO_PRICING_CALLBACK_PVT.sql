--------------------------------------------------------
--  DDL for Package ASO_PRICING_CALLBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICING_CALLBACK_PVT" AUTHID CURRENT_USER as
/* $Header: asovpcls.pls 120.1 2005/06/29 12:43:03 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_CALLBACK_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;

PROCEDURE Config_Callback_Pricing_Order(
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec		     IN	  ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
        p_qte_header_rec	     IN	  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_hd_shipment_rec            IN	  ASO_QUOTE_PUB.Shipment_Rec_Type
    				          := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
        p_hd_price_attr_tbl          IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                          := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        p_qte_line_tbl		     IN	  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_line_rltship_tbl	     IN	  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
    	                                  := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Tbl,
        p_qte_line_dtl_tbl	     IN	  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    				          := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl,
        p_ln_shipment_tbl	     IN	  ASO_QUOTE_PUB.Shipment_Tbl_Type
    				          := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl,
        p_ln_price_attr_tbl	     IN	  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    				          := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        x_qte_header_rec	     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        x_qte_line_tbl		     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        x_qte_line_dtl_tbl	     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
        x_price_adj_tbl		     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        x_price_adj_attr_tbl	     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
        x_price_adj_rltship_tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        x_return_status		     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count		     OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data		     OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

PROCEDURE Config_Callback_Pricing_Order (
        P_Api_Version_Number  IN   NUMBER,
        P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec         IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
        p_qte_line_tbl        IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_qte_header_id       IN   NUMBER,
        x_return_status	      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count           OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data            OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE Copy_Attribs_To_Req(
    p_line_index                            number,
    p_pricing_contexts_Tbl                  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl                QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */            QP_PREQ_GRP.QUAL_TBL_TYPE);

PROCEDURE Copy_hdr_attr_to_line(
    p_line_index                           number,
    p_pricing_contexts_Tbl                 QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl               QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.QUAL_TBL_TYPE);

procedure  Append_asked_for(
       p_header_id                             number := null
       ,p_Line_id                              number := null
       ,p_line_index                           number
       ,px_Req_line_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
       ,px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */           QP_PREQ_GRP.QUAL_TBL_TYPE);


procedure  Append_asked_for(
    p_line_index                           NUMBER,
    p_pricing_attr_tbl                     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    px_Req_line_attr_tbl    in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl         IN OUT NOCOPY /* file.sql.39 change */  QP_PREQ_GRP.QUAL_TBL_TYPE);

procedure copy_Header_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_header_rec                        ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */             QP_PREQ_GRP.LINE_TBL_TYPE);


PROCEDURE Copy_Req_Dtl_To_Price_Adj (
    p_qte_line_index            IN              NUMBER,
    p_qte_line_rec              IN              ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_req_line_dtl_index        IN              NUMBER,
    p_req_line_detail_rec       IN              QP_PREQ_GRP.LINE_DETAIL_REC_TYPE,
    p_req_line_detail_qual_tbl  IN              QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    p_req_line_detail_attr_tbl  IN              QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    px_price_adj_tbl            IN OUT NOCOPY /* file.sql.39 change */            ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    px_price_adj_attr_tbl       IN OUT NOCOPY /* file.sql.39 change */            ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
    px_price_adj_prcd           IN OUT NOCOPY /* file.sql.39 change */            Index_Link_Tbl_Type);

PROCEDURE Copy_Req_Dtl_To_Price_Adj (
    p_qte_header_rec            IN             ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_req_line_dtl_index        IN             NUMBER,
    p_req_line_detail_rec       IN             QP_PREQ_GRP.LINE_DETAIL_REC_TYPE,
    p_req_line_detail_qual_tbl  IN             QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    p_req_line_detail_attr_tbl  IN             QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    px_price_adj_tbl            IN OUT NOCOPY /* file.sql.39 change */           ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    px_price_adj_attr_tbl       IN OUT NOCOPY /* file.sql.39 change */           ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type,
    px_price_adj_prcd           IN OUT NOCOPY /* file.sql.39 change */           Index_Link_Tbl_Type);

procedure copy_Line_to_request(
    p_Request_Type                      VARCHAR2,
    p_pricing_event                     VARCHAR2,
    p_line_rec                          ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_line_dtl_rec                      ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_control_rec      IN               ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
    px_req_line_tbl    IN OUT NOCOPY /* file.sql.39 change */             QP_PREQ_GRP.LINE_TBL_TYPE);

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
    x_price_adj_rltship_tbl       OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type);

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
	x_price_adj_rltship_tbl    OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type);


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
            := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl);


End ASO_PRICING_CALLBACK_PVT;

 

/
