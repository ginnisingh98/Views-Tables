--------------------------------------------------------
--  DDL for Package ASO_PRICING_FLOWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICING_FLOWS_PVT" AUTHID CURRENT_USER as
/* $Header: asovpfls.pls 120.1 2005/06/29 12:43:22 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_FLOWS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;



PROCEDURE Price_Entire_Quote(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
	p_internal_call_flag       IN   VARCHAR2 := 'N',
	--x_qte_line_tbl needed just to obtain free lines during PRG call to update_quote, as they just need the quote_line_id
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Price_Quote_Line(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Price_Quote_With_Change_Lines(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
	p_internal_call_flag       IN   VARCHAR2 := 'N',
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Price_Quote_Calculate_Call(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_delta_line_id_tbl        IN   JTF_NUMBER_TABLE,
     x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


End ASO_PRICING_FLOWS_PVT;

 

/
