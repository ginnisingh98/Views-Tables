--------------------------------------------------------
--  DDL for Package ASO_COPY_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_COPY_QUOTE_PVT" AUTHID CURRENT_USER as
/* $Header: asovcpys.pls 120.2.12010000.3 2010/03/29 14:17:28 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_COPY_QUOTE_PVT
-- Purpose          :
--   This package contains specification for pl/sql records and tables and the
--   Private API of Order Capture.
--
--   Procedures:
--   Copy_Quote
--
-- History          :
-- NOTE             :
--
-- End of Comments
--


PROCEDURE Copy_Quote(
	P_Api_Version_Number         	IN   NUMBER,
    	P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
	P_Copy_Quote_Header_Rec		IN	ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type
									:= ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Header_Rec,
	P_Copy_Quote_Control_Rec		IN	ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
									:= ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec,
        /* Code change for Quoting Usability Sun ER Start */
        P_Qte_Header_Rec           IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
	P_Hd_Shipment_Rec          IN ASO_QUOTE_PUB.Shipment_Rec_Type           := ASO_QUOTE_PUB.G_MISS_Shipment_Rec,
        P_hd_Payment_Tbl	   IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
        P_hd_Tax_Detail_Tbl	   IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
        /* Code change for Quoting Usability Sun ER End */
	X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */   	NUMBER,
	X_Qte_Number			 OUT NOCOPY /* file.sql.39 change */     NUMBER,
	X_Return_Status		 OUT NOCOPY /* file.sql.39 change */   	VARCHAR2,
	X_Msg_Count			 OUT NOCOPY /* file.sql.39 change */   	VARCHAR2,
	X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */   	VARCHAR2 );


PROCEDURE Copy_Header_Rows(
     P_Api_Version_Number          IN   NUMBER,
     P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                      IN   VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.qte_header_rec_Type,
     /* Code change for Quoting Usability Sun ER Start */
     P_Hd_Shipment_Rec	       IN ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_MISS_Shipment_Rec,
     P_hd_Payment_Tbl	       IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
     P_hd_Tax_Detail_Tbl       IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
     /* Code change for Quoting Usability Sun ER End */
     P_Copy_Quote_Control_Rec IN   ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     X_Qte_Header_Id          OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Price_Index_Link_Tbl   OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */     VARCHAR2 );

PROCEDURE Copy_Line_Rows(
     P_Api_Version_Number          IN   NUMBER,
     P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                      IN   VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN   NUMBER,
     P_New_Qte_Header_Id      IN   NUMBER,
     P_Qte_Line_Id            IN   NUMBER   := FND_API.G_MISS_NUM,
     P_Price_Index_Link_Tbl   IN   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
     P_Copy_Quote_Control_Rec IN   ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
     X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */     VARCHAR2 );



PROCEDURE config_copy(
     p_old_config_header_id        IN NUMBER,
     p_old_config_revision_num     IN NUMBER,
     p_config_header_id            IN NUMBER,
     p_config_revision_num         IN NUMBER,
     p_new_qte_header_id           IN NUMBER,
     p_qte_header_id               IN NUMBER,
     p_copy_quote_control_rec      IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
                                        := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec,
     lx_line_index_link_tbl        IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
     lx_price_index_link_tbl       IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
     X_Return_Status               OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     p_line_quantity               IN   NUMBER := FND_API.G_MISS_NUM );

PROCEDURE service_copy(
   p_qte_line_id              IN   NUMBER,
   p_copy_quote_control_rec   IN   ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
                                   := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec,
   p_new_qte_header_id        IN   NUMBER,
   p_qte_header_id            IN   NUMBER,
   lx_line_index_link_tbl     IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   lx_price_index_link_tbl    IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   X_Return_Status            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   X_Msg_Count                OUT NOCOPY /* file.sql.39 change */     NUMBER,
   X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   p_line_quantity            IN   NUMBER := FND_API.G_MISS_NUM);

PROCEDURE Get_Quote_Exp_Date(
   X_Quote_Exp_Date           OUT NOCOPY /* file.sql.39 change */     DATE,
   X_Return_Status            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   X_Msg_Count                OUT NOCOPY /* file.sql.39 change */     NUMBER,
   X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

PROCEDURE COPY_SALES_SUPPLEMENT
(
P_Api_Version_Number          IN         NUMBER,
P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
p_old_quote_header_id         IN         NUMBER,
p_new_quote_header_id         IN         NUMBER,
X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 );


PROCEDURE Copy_Opp_Quote(
   p_api_version_number  IN NUMBER := 1.0,
   p_qte_header_id       IN NUMBER,
   p_new_qte_header_id   IN NUMBER,
   X_Return_Status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
   X_Msg_Count           OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
   X_Msg_Data            OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE Split_Model_Line (
    P_Api_Version_Number   IN NUMBER,
    P_Init_Msg_List        IN VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN VARCHAR2     := FND_API.G_FALSE,
    P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
    P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Original_Qte_Line_Rec  IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Qte_Line_Tbl         IN ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Quote_Line_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Return_Status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2 );


 --  added for sales supp enhancements as per bug 2940126
PROCEDURE INSERT_SALES_SUPP_DATA
(
P_Api_Version_Number          IN         NUMBER,
P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
P_OLD_QUOTE_LINE_ID           IN         NUMBER,
P_NEW_QUOTE_LINE_ID           IN         NUMBER,
X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 );




PROCEDURE copy_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2);
End ASO_COPY_QUOTE_PVT;

/
