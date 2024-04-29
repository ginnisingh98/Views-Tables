--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_VUHK" as
/* $Header: asohqteb.pls 120.1 2005/06/29 12:32:02 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_VUHK
-- Purpose          :
-- This package is the spec required for customer user hooks needed to
-- simplify the customization process. It consists of both the pre and
-- post processing APIs.
G_ASO_STATUS                  VARCHAR2(1) := FND_API.G_MISS_CHAR;
Function Get_Product_Status(p_application_id      NUMBER)
RETURN VARCHAR2 IS
   l_ret_val           BOOLEAN;
   l_status            VARCHAR2(1);
   l_industry          VARCHAR2(1);
BEGIN

   if (p_application_id = 279
		   AND G_ASO_STATUS = FND_API.G_MISS_CHAR)

     then

           -- Make a call to fnd_installation.get function to check for the
           -- installation status of the CRM products and return the status.

           l_ret_val := fnd_installation.get(p_application_id,p_application_id
                         ,l_status,l_industry);
           if p_application_id = 279         then
               G_ASO_STATUS := l_status;
            end if;

    end if;

    if p_application_id = 279 then
      return (G_ASO_STATUS);
    end if;

END Get_Product_Status;
PROCEDURE Create_quote_PRE(
    P_Validation_Level 	 IN OUT NOCOPY   NUMBER       ,
    P_Control_Rec		 IN OUT NOCOPY   ASO_QUOTE_PUB.Control_Rec_Type ,
    P_Qte_Header_Rec		 IN OUT NOCOPY    ASO_QUOTE_PUB.Qte_Header_Rec_Type  ,
    P_hd_Price_Attributes_Tbl	 IN OUT NOCOPY   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_hd_Payment_Tbl		 IN OUT NOCOPY   ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_hd_Shipment_Rec		 IN OUT NOCOPY   ASO_QUOTE_PUB.Shipment_Rec_Type,
    P_hd_Freight_Charge_Tbl	 IN OUT NOCOPY   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_hd_Tax_Detail_Tbl		 IN OUT NOCOPY   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_hd_Sales_Credit_Tbl        IN OUT NOCOPY ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_hd_Quote_Party_Tbl         IN OUT NOCOPY ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Line_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Tbl_Type ,
    P_Qte_Line_Dtl_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attr_Ext_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_line_rltship_tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    P_Price_Adjustment_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Price_Adj_Rltship_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    P_Ln_Price_Attributes_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Ln_Payment_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type ,
    P_Ln_Shipment_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Ln_Freight_Charge_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Ln_Tax_Detail_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_ln_Sales_Credit_Tbl        IN OUT NOCOPY ASO_QUOTE_PUB.   Sales_Credit_Tbl_Type,
    P_ln_Quote_Party_Tbl         IN OUT NOCOPY ASO_QUOTE_PUB.   Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS
BEGIN
NULL;

--dbms_output.put_line('Keep Smiling');
--p_qte_header_rec.cust_Account_id := 1006;

END;



PROCEDURE Create_quote_POST(
     P_Validation_Level 	IN    NUMBER       ,
    P_Control_Rec		 IN    ASO_QUOTE_PUB.Control_Rec_Type ,
    P_Qte_Header_Rec		 IN      ASO_QUOTE_PUB.Qte_Header_Rec_Type  ,
    P_hd_Price_Attributes_Tbl	 IN     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_hd_Payment_Tbl		 IN     ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_hd_Shipment_Rec		 IN     ASO_QUOTE_PUB.Shipment_Rec_Type,
    P_hd_Freight_Charge_Tbl	 IN     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_hd_Tax_Detail_Tbl		 IN     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_hd_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_hd_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Line_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type ,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    P_Ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type ,
    P_Ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_ln_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.   Sales_Credit_Tbl_Type,
    P_ln_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.   Quote_Party_Tbl_Type,
    X_Return_Status                OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS
l_sql_stat                    VARCHAR2(3000);
l_init_msg_list               VARCHAR2(240);
l_commit                      VARCHAR2(1);
l_msg_count                   NUMBER;
l_validation_level   NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);

BEGIN
NULL;

END;





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL;
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */    NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_quote_PRE(
     P_Validation_Level 	IN OUT NOCOPY   NUMBER       ,
    P_Control_Rec		 IN OUT NOCOPY   ASO_QUOTE_PUB.Control_Rec_Type ,
    P_Qte_Header_Rec		 IN OUT NOCOPY    ASO_QUOTE_PUB.Qte_Header_Rec_Type  ,
    P_hd_Price_Attributes_Tbl	 IN OUT NOCOPY   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_hd_Payment_Tbl		 IN OUT NOCOPY   ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_hd_Shipment_tbl		 IN OUT NOCOPY   ASO_QUOTE_PUB.Shipment_tbl_Type,
    P_hd_Freight_Charge_Tbl	 IN OUT NOCOPY   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_hd_Tax_Detail_Tbl		 IN OUT NOCOPY   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_hd_Sales_Credit_Tbl        IN OUT NOCOPY ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_hd_Quote_Party_Tbl         IN OUT NOCOPY ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Line_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Tbl_Type ,
    P_Qte_Line_Dtl_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attr_Ext_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_line_rltship_tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    P_Price_Adjustment_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Price_Adj_Rltship_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    P_Ln_Price_Attributes_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Ln_Payment_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type ,
    P_Ln_Shipment_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Ln_Freight_Charge_Tbl	 IN OUT NOCOPY ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Ln_Tax_Detail_Tbl		 IN OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_ln_Sales_Credit_Tbl        IN OUT NOCOPY ASO_QUOTE_PUB.   Sales_Credit_Tbl_Type,
    P_ln_Quote_Party_Tbl         IN OUT NOCOPY ASO_QUOTE_PUB.   Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS
BEGIN
NULL;
END;



PROCEDURE UPdate_quote_POST(
     P_Validation_Level 	IN    NUMBER       ,
    P_Control_Rec		 IN    ASO_QUOTE_PUB.Control_Rec_Type ,
    P_Qte_Header_Rec		 IN      ASO_QUOTE_PUB.Qte_Header_Rec_Type  ,
    P_hd_Price_Attributes_Tbl	 IN     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_hd_Payment_Tbl		 IN     ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_hd_Shipment_tbl		 IN     ASO_QUOTE_PUB.Shipment_tbl_Type,
    P_hd_Freight_Charge_Tbl	 IN     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_hd_Tax_Detail_Tbl		 IN     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_hd_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_hd_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Line_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type ,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    P_Ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type ,
    P_Ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_ln_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.   Sales_Credit_Tbl_Type,
    P_ln_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.   Quote_Party_Tbl_Type,
    X_Return_Status                OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS
BEGIN
NULL;
END;





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL;
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */    NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_quote_PRE(
    P_Qte_Header_Id		 IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
BEGIN
NULL;
END;


PROCEDURE Delete_quote_POST(
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
BEGIN
NULL;
END;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Copy_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Copy_quote_PRE(
    P_Qte_Header_Id		 IN OUT NOCOPY   NUMBER,
    P_Last_Update_Date		 IN OUT NOCOPY  DATE,
    P_Copy_Only_Header		 IN OUT NOCOPY  VARCHAR2,
    P_New_Version		 IN OUT NOCOPY  VARCHAR2,
    P_Qte_Status_Id		 IN OUT NOCOPY  NUMBER	,
    P_Qte_Number		 IN OUT NOCOPY  NUMBER	,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
BEGIN
NULL;
END;


PROCEDURE Copy_quote_POST(
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	 ,
    P_New_Version		 IN   VARCHAR2	 ,
    P_Qte_Status_Id		 IN   NUMBER	 ,
    P_Qte_Number		 IN   NUMBER	,
    P_NEW_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_sql_stat                    VARCHAR2(3000);
l_init_msg_list               VARCHAR2(240);
l_commit                      VARCHAR2(1);
l_msg_count                   NUMBER;
l_validation_level   NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);

BEGIN
NULL;
END;






--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Submit_quote_PRE(
    p_control_rec		 IN OUT NOCOPY  ASO_QUOTE_PUB.Submit_Control_Rec_Type,
    P_Qte_Header_Id		 IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
BEGIN
NULL;
END;


PROCEDURE Submit_quote_POST(
    p_control_rec		 IN   ASO_QUOTE_PUB.Submit_Control_Rec_Type ,
    P_Qte_Header_Id		 IN   NUMBER,
    p_order_header_rec		 IN  ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )IS
BEGIN
NULL;
END;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Detail_Tbl      IN    Tax_Detail_Tbl_Type
--       P_Freight_Charge_Tbl  IN    Freight_Charge_Tbl_Type
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Rltship_Tbl IN Price_Adj_Rltship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE

--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */   NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--


-- do not need defaults because they are already defaulted in the call to
-- the public api
--   End of Comments
--
PROCEDURE Create_Quote_Line_PRE(
    P_Qte_Line_Rec         IN  OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Control_Rec          IN  OUT NOCOPY ASO_QUOTE_PUB.Control_rec_Type,
    P_Qte_Line_Dtl_Tbl    IN   OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attribs_Ext_Tbl IN   OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    P_Payment_Tbl          IN   OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Price_Adj_Tbl        IN   OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Tbl_Type ,
    P_Price_Attributes_Tbl IN   OUT NOCOPY ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Price_Adj_Attr_Tbl    IN  OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Shipment_Tbl          IN  OUT NOCOPY ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Tax_Detail_Tbl        IN  OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_Freight_Charge_Tbl    IN  OUT NOCOPY ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Sales_Credit_Tbl      IN  OUT NOCOPY ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ,
    P_Quote_Party_Tbl       IN  OUT NOCOPY ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Update_Header_Flag    IN  OUT NOCOPY VARCHAR2,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)IS
BEGIN
NULL;
END;



PROCEDURE Create_Quote_Line_POST(
    P_Qte_Line_Rec         IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Control_Rec          IN   ASO_QUOTE_PUB.Control_rec_Type,
    P_Qte_Line_Dtl_Tbl    IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attribs_Ext_Tbl IN    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    P_Payment_Tbl          IN    ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Price_Adj_Tbl        IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Attributes_Tbl IN    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Update_Header_Flag    IN   VARCHAR2  ,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)IS
BEGIN
NULL;
END;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN


PROCEDURE Update_Quote_Line_PRE(
    P_Qte_Line_Rec         IN  OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Control_Rec          IN  OUT NOCOPY ASO_QUOTE_PUB.Control_rec_Type,
    P_Qte_Line_Dtl_Tbl    IN   OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attribs_Ext_Tbl IN   OUT NOCOPY ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    P_Payment_Tbl          IN   OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Price_Adj_Tbl        IN   OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Tbl_Type ,
    P_Price_Attributes_Tbl IN   OUT NOCOPY ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Price_Adj_Attr_Tbl    IN  OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Shipment_Tbl          IN  OUT NOCOPY ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Tax_Detail_Tbl        IN  OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_Freight_Charge_Tbl    IN  OUT NOCOPY ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Sales_Credit_Tbl      IN  OUT NOCOPY ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ,
    P_Quote_Party_Tbl       IN  OUT NOCOPY ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Update_Header_Flag    IN  OUT NOCOPY VARCHAR2,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)IS
BEGIN
NULL;
END;



PROCEDURE Update_Quote_Line_POST(
    P_Qte_Line_Rec         IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Control_Rec          IN   ASO_QUOTE_PUB.Control_rec_Type,
    P_Qte_Line_Dtl_Tbl    IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    P_Line_Attribs_Ext_Tbl IN    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    P_Payment_Tbl          IN    ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Price_Adj_Tbl        IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Attributes_Tbl IN    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Update_Header_Flag    IN   VARCHAR2  ,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)IS
BEGIN
NULL;
END;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL;
--       P_qte_line_Rec      IN qte_line_Rec_Type  Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_Quote_Line_PRE(
    P_qte_line_Rec     IN  OUT NOCOPY   ASO_QUOTE_PUB.qte_line_Rec_Type,
    P_Control_Rec      IN  OUT NOCOPY   ASO_QUOTE_PUB.Control_rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )IS
BEGIN
NULL;
END;

PROCEDURE Delete_Quote_Line_POST(
    P_qte_line_Rec     IN     ASO_QUOTE_PUB.qte_line_Rec_Type,
    P_Control_Rec      IN     ASO_QUOTE_PUB.Control_rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
BEGIN
NULL;
END;


PROCEDURE Allocate_Sales_Credits_PRE(
            p_control_rec        IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE,
            P_Qte_Header_Id      IN   NUMBER,
            X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
            X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
            X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
BEGIN

NULL;

END;


PROCEDURE Allocate_Sales_Credits_POST(
           p_control_rec        IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE,
           P_Qte_Header_Rec     IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
           X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
           X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
           X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
BEGIN

NULL;

END;

End ASO_QUOTE_VUHK;

/
