--------------------------------------------------------
--  DDL for Package ASO_COPY_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_COPY_QUOTE_PUB" AUTHID CURRENT_USER as
/* $Header: asopcpys.pls 120.2.12010000.3 2010/03/17 06:18:58 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_COPY_QUOTE_PUB
-- Purpose          :
--   This package contains specification for pl/sql records and tables and the
--   Public API of Order Capture.
--
--   Record Type:
--   Copy_Quote_Control_Rec_Type
--   Copy_Quote_Header_Rec_Type
--
--   Procedures:
--   Copy_Quote
--
-- History          :
-- NOTE             :
--
-- End of Comments
--


TYPE Copy_Quote_Control_Rec_Type IS RECORD
(
	Copy_Header_Only		     VARCHAR2(1) := FND_API.G_FALSE,
	New_Version			     VARCHAR2(1) := FND_API.G_FALSE,
	Copy_Note				     VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Task				     VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Attachment		     VARCHAR2(1) := FND_API.G_TRUE,
	Pricing_Request_Type	     VARCHAR2(30) := 'ASO',
	Header_Pricing_Event	     VARCHAR2(30) := FND_API.G_MISS_CHAR,
	Price_Mode	               VARCHAR2(30) := 'ENTIRE_QUOTE',
	Calculate_Freight_Charge_Flag	VARCHAR2(1) := FND_API.G_MISS_CHAR,
	Calculate_Tax_Flag		     VARCHAR2(1) := FND_API.G_MISS_CHAR,
	/* Code change for Quoting Usability Sun ER Start */
	Copy_Shipping              VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Billing               VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Payment               VARCHAR2(1) := FND_API.G_TRUE,
	Copy_End_Customer          VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Sales_Supplement      VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Flexfield             VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Sales_Credit          VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Contract_Terms        VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Sales_Team            VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Shipping         VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Billing          VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Payment          VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_End_Customer     VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Sales_Supplement VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Attachment       VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Flexfield        VARCHAR2(1) := FND_API.G_TRUE,
	Copy_Line_Sales_Credit     VARCHAR2(1) := FND_API.G_TRUE,
	Copy_To_Same_Customer      VARCHAR2(1) := FND_API.G_TRUE
        /* Code change for Quoting Usability Sun ER End */
);

G_MISS_Copy_Quote_Control_Rec	Copy_Quote_Control_Rec_Type;

TYPE Copy_Quote_Header_Rec_Type IS RECORD
(
	Quote_Header_Id		      NUMBER		:= FND_API.G_MISS_NUM,
	Quote_Name			      VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
	Quote_Number			      NUMBER        := FND_API.G_MISS_NUM,
	Quote_Source_Code		      VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
	Quote_Expiration_Date	      DATE		:= FND_API.G_MISS_DATE,
	Resource_Id			      NUMBER        := FND_API.G_MISS_NUM,
	Resource_Grp_Id		      NUMBER        := FND_API.G_MISS_NUM,
     PRICING_STATUS_INDICATOR       VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
     TAX_STATUS_INDICATOR           VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
     PRICE_UPDATED_DATE             DATE          :=  FND_API.G_MISS_DATE,
     TAX_UPDATED_DATE               DATE          :=  FND_API.G_MISS_DATE
);

G_MISS_Copy_Quote_Header_Rec Copy_Quote_Header_Rec_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Copy_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Copy_Quote_Header_Rec   IN 	Copy_Quote_Header_Rec_Type Default = G_MISS_Copy_Quote_Header_Rec
--       P_Copy_Quote_Control_Rec   IN 	Copy_Quote_Control_Rec_Type Default = G_MISS_Copy_Quote_Control_Rec
--
--   OUT:
--	    x_qte_header_id		 OUT NOCOPY /* file.sql.39 change */ NUMBER
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
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
	P_hd_Shipment_Rec          IN  ASO_QUOTE_PUB.Shipment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Shipment_Rec,
        P_hd_Payment_Tbl	   IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
        P_hd_Tax_Detail_Tbl	   IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
        /* Code change for Quoting Usability Sun ER End */
	X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
	X_Qte_Number			 OUT NOCOPY /* file.sql.39 change */    NUMBER,
	X_Return_Status		 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	X_Msg_Count			 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2 );



PROCEDURE Copy_Line(
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN  NUMBER,
     P_Qte_Line_Id            IN  NUMBER   := NULL,
     P_Copy_Quote_Control_Rec IN  ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
	X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */    NUMBER,
	X_Return_Status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2 );

 -- Overloaded Copy Line created for bug 4339146
PROCEDURE Copy_Line(
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN  NUMBER,
     P_Qte_Line_Id            IN  NUMBER   := NULL,
     P_Copy_Quote_Control_Rec IN  ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
     X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */  NUMBER,
     X_Qte_Header_Rec         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2 );
End ASO_COPY_QUOTE_PUB;


/
