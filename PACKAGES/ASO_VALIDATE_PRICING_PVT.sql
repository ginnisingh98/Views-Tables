--------------------------------------------------------
--  DDL for Package ASO_VALIDATE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_VALIDATE_PRICING_PVT" AUTHID CURRENT_USER as
/* $Header: asovvprs.pls 120.1 2005/06/29 12:45:57 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_VALIDATE_PRICING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


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
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


End ASO_VALIDATE_PRICING_PVT;

 

/
