--------------------------------------------------------
--  DDL for Package Body ASO_DEFAULTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEFAULTING_UTIL" AS
/* $Header: asovdhub.pls 120.5.12010000.2 2011/05/30 16:31:34 akushwah ship $ */
-- Package name     : ASO_DEFAULTING_UTIL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE  Api_Rec_To_Row_Type
          (
           P_Entity_Code                 IN        VARCHAR2,
           P_Quote_Header_Rec            IN        ASO_Quote_Pub.Qte_Header_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Qte_Header_Rec,
           P_Header_Shipment_Rec         IN        ASO_Quote_Pub.Shipment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Shipment_Rec,
           P_Header_Payment_Rec          IN        ASO_Quote_Pub.Payment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Payment_Rec,
           P_Quote_Line_Rec              IN        ASO_Quote_Pub.Qte_Line_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Qte_Line_Rec,
           P_Line_Shipment_Rec           IN        ASO_Quote_Pub.Shipment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Shipment_Rec,
           P_Line_Payment_Rec            IN        ASO_Quote_Pub.Payment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Payment_Rec,
           P_Control_Rec                 IN        ASO_Defaulting_Int.Control_Rec_Type
                                                   := ASO_Defaulting_Int.G_Miss_Control_Rec,
           P_OPP_QTE_HEADER_REC          IN        ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE
                                                   := ASO_OPP_QTE_PUB.G_MISS_OPP_QTE_IN_REC,
           P_HEADER_MISC_REC             IN        ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE
                                                   := ASO_DEFAULTING_INT.G_MISS_HEADER_MISC_REC,
           P_HEADER_TAX_DETAIL_REC       IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                                   := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
           P_LINE_MISC_REC               IN        ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE
                                                   := ASO_DEFAULTING_INT.G_MISS_LINE_MISC_REC,
           P_LINE_TAX_DETAIL_REC         IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                                   := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
           X_Qte_Header_Row_Rec          IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Header_V%Rowtype,
           X_Qte_Opportunity_Row_Rec    IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Oppty_V%Rowtype,
           X_Qte_Line_Row_Rec           IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Line_V%Rowtype)

IS

 CURSOR C_Party_Type(lc_party_id NUMBER) IS
  SELECT Party_Type
  FROM HZ_PARTIES
  WHERE Party_Id = lc_party_id;

 CURSOR C_Line_Party_Type(lc_quote_header_id NUMBER) IS
  SELECT pty.Party_Type
  FROM HZ_PARTIES pty, ASO_QUOTE_HEADERS_ALL hdr
  WHERE pty.Party_Id = hdr.cust_party_id
  AND hdr.quote_header_id = lc_quote_header_id;

 CURSOR C_Product (lc_inv_item_id NUMBER, lc_organization_id NUMBER) IS
  SELECT Segment1
  FROM mtl_system_items_vl
  WHERE inventory_item_id = lc_inv_item_id
  AND organization_id = lc_organization_id;

BEGIN

       IF P_Entity_Code = 'QUOTE_HEADER' THEN

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_NAME IS NULL THEN
          X_Qte_Header_Row_Rec.Q_QUOTE_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_QUOTE_NAME := P_Quote_Header_Rec.QUOTE_NAME;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_HEADER_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID := P_Quote_Header_Rec.QUOTE_HEADER_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID := P_Quote_Header_Rec.CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_EXPIRATION_DATE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE :=  P_Quote_Header_Rec.QUOTE_EXPIRATION_DATE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_STATUS_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID := P_Quote_Header_Rec.QUOTE_STATUS_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ORG_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ORG_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_ORG_ID := P_Quote_Header_Rec.ORG_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CREATED_BY IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CREATED_BY := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_CREATED_BY := P_Quote_Header_Rec.CREATED_BY;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ORDER_TYPE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID := P_Quote_Header_Rec.ORDER_TYPE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CONTRACT_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CONTRACT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_CONTRACT_ID := P_Quote_Header_Rec.CONTRACT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PRICE_LIST_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PRICE_LIST_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_PRICE_LIST_ID := P_Quote_Header_Rec.PRICE_LIST_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CURRENCY_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CURRENCY_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_CURRENCY_CODE  := P_Quote_Header_Rec.CURRENCY_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PRICE_FROZEN_DATE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE := P_Quote_Header_Rec.PRICE_FROZEN_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CONTRACT_TEMPLATE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID := P_Quote_Header_Rec.CONTRACT_TEMPLATE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.RESOURCE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_RESOURCE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_RESOURCE_ID :=  P_Quote_Header_Rec.RESOURCE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.RESOURCE_GRP_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID := P_Quote_Header_Rec.RESOURCE_GRP_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.SALES_CHANNEL_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE  := P_Quote_Header_Rec.SALES_CHANNEL_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID := P_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_PARTY_ID := P_Quote_Header_Rec.PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PHONE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PHONE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_PHONE_ID := P_Quote_Header_Rec.PHONE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
        /*** Start : Code change done for Bug 12406449 ***/
        ELSIF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING FORM' AND
              p_control_rec.defaulting_flow_code like 'CREATE%' AND
              P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID IS NOT NULL AND
	      P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM THEN
              X_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
        /*** End : Code change done for Bug 12406449 ***/
        ELSE
		X_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID := P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID := P_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID := P_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID := P_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID := P_Quote_Header_Rec.INVOICE_TO_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CUST_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CUST_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_CUST_PARTY_ID := P_Quote_Header_Rec.CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID := P_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID := P_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID := P_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID := P_Quote_Header_Rec.END_CUSTOMER_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG IS NULL THEN
          X_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG := P_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.AUTOMATIC_TAX_FLAG IS NULL THEN
          X_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG := P_Quote_Header_Rec.AUTOMATIC_TAX_FLAG;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.LAST_UPDATE_DATE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE := P_Quote_Header_Rec.LAST_UPDATE_DATE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.OBJECT_VERSION_NUMBER IS NULL THEN
          X_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER := P_Quote_Header_Rec.OBJECT_VERSION_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE_CATEGORY IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY := P_Quote_Header_Rec.ATTRIBUTE_CATEGORY;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE1 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE1 := P_Quote_Header_Rec.ATTRIBUTE1;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE2 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE2 := P_Quote_Header_Rec.ATTRIBUTE2;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE3 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE3 := P_Quote_Header_Rec.ATTRIBUTE3;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE4 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE4 := P_Quote_Header_Rec.ATTRIBUTE4;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE5 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE5 := P_Quote_Header_Rec.ATTRIBUTE5;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE6 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE6 := P_Quote_Header_Rec.ATTRIBUTE6;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE7 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE7 := P_Quote_Header_Rec.ATTRIBUTE7;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE8 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE8 := P_Quote_Header_Rec.ATTRIBUTE8;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE9 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE9 := P_Quote_Header_Rec.ATTRIBUTE9;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE10 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE10 := P_Quote_Header_Rec.ATTRIBUTE10;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE11 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE11 := P_Quote_Header_Rec.ATTRIBUTE11;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE12 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE12 := P_Quote_Header_Rec.ATTRIBUTE12;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE13 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE13 := P_Quote_Header_Rec.ATTRIBUTE13;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE14 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE14 := P_Quote_Header_Rec.ATTRIBUTE14;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE15 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE15 := P_Quote_Header_Rec.ATTRIBUTE15;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE16 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE16 := P_Quote_Header_Rec.ATTRIBUTE16;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE17 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE17 := P_Quote_Header_Rec.ATTRIBUTE17;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE18 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE18 := P_Quote_Header_Rec.ATTRIBUTE18;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE19 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE19 := P_Quote_Header_Rec.ATTRIBUTE19;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE20 IS NULL THEN
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_ATTRIBUTE20 := P_Quote_Header_Rec.ATTRIBUTE20;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID :=P_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID := P_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID := P_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_PARTY_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID := P_Header_Shipment_Rec.SHIP_TO_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_TERM_ID IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID := P_Header_Payment_Rec.PAYMENT_TERM_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CUST_PO_NUMBER IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER := P_Header_Payment_Rec.CUST_PO_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE := P_Header_Payment_Rec.CREDIT_CARD_CODE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_REF_NUMBER IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER := P_Header_Payment_Rec.PAYMENT_REF_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME := P_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE := P_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_TYPE_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE := P_Header_Payment_Rec.PAYMENT_TYPE_CODE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.REQUEST_DATE_TYPE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE := P_Header_Shipment_Rec.REQUEST_DATE_TYPE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.REQUEST_DATE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_REQUEST_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Header_Row_Rec.Q_REQUEST_DATE := P_Header_Shipment_Rec.REQUEST_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_METHOD_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE := P_Header_Shipment_Rec.SHIP_METHOD_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE := P_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.FREIGHT_TERMS_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE := P_Header_Shipment_Rec.FREIGHT_TERMS_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.FOB_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_FOB_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_FOB_CODE := P_Header_Shipment_Rec.FOB_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS IS NULL THEN
          X_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS := P_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.PACKING_INSTRUCTIONS IS NULL THEN
          X_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS := P_Header_Shipment_Rec.PACKING_INSTRUCTIONS;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.DEMAND_CLASS_CODE IS NULL THEN
          X_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE := P_Header_Shipment_Rec.DEMAND_CLASS_CODE;
        END IF;

		X_Qte_Header_Row_Rec.Q_APPLICATION_TYPE_CODE := P_Control_Rec.APPLICATION_TYPE_CODE;

          OPEN C_Party_Type(P_Quote_Header_Rec.CUST_PARTY_ID);
          FETCH C_Party_Type INTO X_Qte_Header_Row_Rec.Q_QUOTE_CUSTOMER_TYPE;
          CLOSE C_Party_Type;

      ELSIF P_Entity_Code = 'QUOTE_OPPTY' THEN

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_NAME IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_QUOTE_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_QUOTE_NAME := P_Quote_Header_Rec.QUOTE_NAME;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_HEADER_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID := P_Quote_Header_Rec.QUOTE_HEADER_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID := P_Quote_Header_Rec.CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_EXPIRATION_DATE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE :=  P_Quote_Header_Rec.QUOTE_EXPIRATION_DATE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.QUOTE_STATUS_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID := P_Quote_Header_Rec.QUOTE_STATUS_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ORG_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ORG_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_ORG_ID := P_Quote_Header_Rec.ORG_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CREATED_BY IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CREATED_BY := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CREATED_BY := P_Quote_Header_Rec.CREATED_BY;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ORDER_TYPE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID := P_Quote_Header_Rec.ORDER_TYPE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CONTRACT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CONTRACT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CONTRACT_ID := P_Quote_Header_Rec.CONTRACT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PRICE_LIST_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID := P_Quote_Header_Rec.PRICE_LIST_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CURRENCY_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE  := P_Quote_Header_Rec.CURRENCY_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PRICE_FROZEN_DATE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE := P_Quote_Header_Rec.PRICE_FROZEN_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CONTRACT_TEMPLATE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID := P_Quote_Header_Rec.CONTRACT_TEMPLATE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.RESOURCE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_RESOURCE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_RESOURCE_ID :=  P_Quote_Header_Rec.RESOURCE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.RESOURCE_GRP_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID := P_Quote_Header_Rec.RESOURCE_GRP_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.SALES_CHANNEL_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE  := P_Quote_Header_Rec.SALES_CHANNEL_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID := P_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_PARTY_ID := P_Quote_Header_Rec.PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.PHONE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PHONE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_PHONE_ID := P_Quote_Header_Rec.PHONE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID := P_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID := P_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID := P_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID := P_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.INVOICE_TO_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_INV_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_INV_PTY_ID := P_Quote_Header_Rec.INVOICE_TO_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.CUST_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID := P_Quote_Header_Rec.CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID := P_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID := P_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID := P_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.END_CUSTOMER_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID := P_Quote_Header_Rec.END_CUSTOMER_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG := P_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.AUTOMATIC_TAX_FLAG IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG := P_Quote_Header_Rec.AUTOMATIC_TAX_FLAG;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.LAST_UPDATE_DATE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE := P_Quote_Header_Rec.LAST_UPDATE_DATE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.OBJECT_VERSION_NUMBER IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER := P_Quote_Header_Rec.OBJECT_VERSION_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE_CATEGORY IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY := P_Quote_Header_Rec.ATTRIBUTE_CATEGORY;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE1 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1 := P_Quote_Header_Rec.ATTRIBUTE1;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE2 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2 := P_Quote_Header_Rec.ATTRIBUTE2;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE3 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3 := P_Quote_Header_Rec.ATTRIBUTE3;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE4 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4 := P_Quote_Header_Rec.ATTRIBUTE4;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE5 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5 := P_Quote_Header_Rec.ATTRIBUTE5;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE6 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6 := P_Quote_Header_Rec.ATTRIBUTE6;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE7 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7 := P_Quote_Header_Rec.ATTRIBUTE7;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE8 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8 := P_Quote_Header_Rec.ATTRIBUTE8;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE9 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9 := P_Quote_Header_Rec.ATTRIBUTE9;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE10 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10 := P_Quote_Header_Rec.ATTRIBUTE10;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE11 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11 := P_Quote_Header_Rec.ATTRIBUTE11;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE12 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12 := P_Quote_Header_Rec.ATTRIBUTE12;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE13 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13 := P_Quote_Header_Rec.ATTRIBUTE13;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE14 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14 := P_Quote_Header_Rec.ATTRIBUTE14;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE15 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15 := P_Quote_Header_Rec.ATTRIBUTE15;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE16 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16 := P_Quote_Header_Rec.ATTRIBUTE16;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE17 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17 := P_Quote_Header_Rec.ATTRIBUTE17;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE18 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18 := P_Quote_Header_Rec.ATTRIBUTE18;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE19 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19 := P_Quote_Header_Rec.ATTRIBUTE19;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Header_Rec.ATTRIBUTE20 IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20 := P_Quote_Header_Rec.ATTRIBUTE20;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID :=P_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID := P_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID := P_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_TO_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID := P_Header_Shipment_Rec.SHIP_TO_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_TERM_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID := P_Header_Payment_Rec.PAYMENT_TERM_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CUST_PO_NUMBER IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER := P_Header_Payment_Rec.CUST_PO_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE := P_Header_Payment_Rec.CREDIT_CARD_CODE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_REF_NUMBER IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER := P_Header_Payment_Rec.PAYMENT_REF_NUMBER ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME := P_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE := P_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Payment_Rec.PAYMENT_TYPE_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE := P_Header_Payment_Rec.PAYMENT_TYPE_CODE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.REQUEST_DATE_TYPE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE := P_Header_Shipment_Rec.REQUEST_DATE_TYPE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.REQUEST_DATE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_REQUEST_DATE := FND_API.G_MISS_DATE;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_REQUEST_DATE := P_Header_Shipment_Rec.REQUEST_DATE ;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIP_METHOD_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE := P_Header_Shipment_Rec.SHIP_METHOD_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE := P_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.FREIGHT_TERMS_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE := P_Header_Shipment_Rec.FREIGHT_TERMS_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.FOB_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_FOB_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_FOB_CODE := P_Header_Shipment_Rec.FOB_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS := P_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.PACKING_INSTRUCTIONS IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS := P_Header_Shipment_Rec.PACKING_INSTRUCTIONS;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Header_Shipment_Rec.DEMAND_CLASS_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
        ELSE
		X_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE := P_Header_Shipment_Rec.DEMAND_CLASS_CODE;
        END IF;

		X_Qte_Opportunity_Row_Rec.O_APPLICATION_TYPE_CODE := P_Control_Rec.APPLICATION_TYPE_CODE;

          OPEN C_Party_Type(P_Quote_Header_Rec.CUST_PARTY_ID);
          FETCH C_Party_Type INTO X_Qte_Opportunity_Row_Rec.O_QUOTE_TO_CUST_TYPE;
          CLOSE C_Party_Type;


        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.OPPORTUNITY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_ID := P_Opp_Qte_Header_Rec.OPPORTUNITY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.CURRENCY_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CURRENCY_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CURRENCY_CODE := P_Opp_Qte_Header_Rec.CURRENCY_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.CHANNEL_CODE IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CHANNEL_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CHANNEL_CODE := P_Opp_Qte_Header_Rec.CHANNEL_CODE;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.QUOTE_NAME IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_QUOTE_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_QUOTE_NAME := P_Opp_Qte_Header_Rec.QUOTE_NAME;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.CUST_PARTY_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CUST_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_CUST_PARTY_ID := P_Opp_Qte_Header_Rec.CUST_PARTY_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.MARKETING_SOURCE_CODE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_MKTG_SRC_CD_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_MKTG_SRC_CD_ID := P_Opp_Qte_Header_Rec.MARKETING_SOURCE_CODE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_PTY_ST_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_PTY_ST_ID := P_Opp_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;
        END IF;

        IF P_Control_Rec.APPLICATION_TYPE_CODE = 'QUOTING HTML' AND
           p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Opp_Qte_Header_Rec.SOLD_TO_CONTACT_ID IS NULL THEN
          X_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_TO_CONT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_TO_CONT_ID := P_Opp_Qte_Header_Rec.SOLD_TO_CONTACT_ID;
        END IF;

      ELSIF P_Entity_Code = 'QUOTE_LINE' THEN

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.QUOTE_HEADER_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID := P_Quote_Line_Rec.QUOTE_HEADER_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.QUOTE_LINE_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_QUOTE_LINE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_QUOTE_LINE_ID := P_Quote_Line_Rec.QUOTE_LINE_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.LAST_UPDATE_DATE IS NULL THEN
          X_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE := P_Quote_Line_Rec.LAST_UPDATE_DATE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.OBJECT_VERSION_NUMBER IS NULL THEN
          X_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER := P_Quote_Line_Rec.OBJECT_VERSION_NUMBER;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE_CATEGORY IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY := P_Quote_Line_Rec.ATTRIBUTE_CATEGORY;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE1 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE1 := P_Quote_Line_Rec.ATTRIBUTE1;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE2 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE2 := P_Quote_Line_Rec.ATTRIBUTE2;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE3 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE3 := P_Quote_Line_Rec.ATTRIBUTE3;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE4 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE4 := P_Quote_Line_Rec.ATTRIBUTE4;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE5 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE5 := P_Quote_Line_Rec.ATTRIBUTE5;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE6 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE6 := P_Quote_Line_Rec.ATTRIBUTE6;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE7 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE7 := P_Quote_Line_Rec.ATTRIBUTE7;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE8 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE8 := P_Quote_Line_Rec.ATTRIBUTE8;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE9 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE9 := P_Quote_Line_Rec.ATTRIBUTE9;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE10 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE10 := P_Quote_Line_Rec.ATTRIBUTE10;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE11 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE11 := P_Quote_Line_Rec.ATTRIBUTE11;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE12 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE12 := P_Quote_Line_Rec.ATTRIBUTE12;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE13 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE13 := P_Quote_Line_Rec.ATTRIBUTE13;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE14 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE14 := P_Quote_Line_Rec.ATTRIBUTE14;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE15 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE15 := P_Quote_Line_Rec.ATTRIBUTE15;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE16 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE16 := P_Quote_Line_Rec.ATTRIBUTE16;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE17 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE17 := P_Quote_Line_Rec.ATTRIBUTE17;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE18 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE18 := P_Quote_Line_Rec.ATTRIBUTE18;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE19 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE19 := P_Quote_Line_Rec.ATTRIBUTE19;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ATTRIBUTE20 IS NULL THEN
          X_Qte_Line_Row_Rec.L_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ATTRIBUTE20 := P_Quote_Line_Rec.ATTRIBUTE20;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.CREATED_BY IS NULL THEN
          X_Qte_Line_Row_Rec.L_CREATED_BY := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_CREATED_BY := P_Quote_Line_Rec.CREATED_BY;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ORG_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_ORG_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_ORG_ID := P_Quote_Line_Rec.ORG_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ORDER_LINE_TYPE_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID := P_Quote_Line_Rec.ORDER_LINE_TYPE_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.LINE_CATEGORY_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE := P_Quote_Line_Rec.LINE_CATEGORY_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.CHARGE_PERIODICITY_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_PERIODICITY_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_PERIODICITY_CODE := P_Quote_Line_Rec.CHARGE_PERIODICITY_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.AGREEMENT_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_AGREEMENT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_AGREEMENT_ID := P_Quote_Line_Rec.AGREEMENT_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.PRICE_LIST_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_PRICE_LIST_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_PRICE_LIST_ID := P_Quote_Line_Rec.PRICE_LIST_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID := P_Quote_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.INVOICE_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID := P_Quote_Line_Rec.INVOICE_TO_CUST_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.INVOICE_TO_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_INV_TO_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_INV_TO_PTY_ID := P_Quote_Line_Rec.INVOICE_TO_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.INVOICE_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID := P_Quote_Line_Rec.INVOICE_TO_PARTY_SITE_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID := P_Line_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_TO_CUST_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID := P_Line_Shipment_Rec.SHIP_TO_CUST_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_TO_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID := P_Line_Shipment_Rec.SHIP_TO_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_TO_PARTY_SITE_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID := P_Line_Shipment_Rec.SHIP_TO_PARTY_SITE_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.END_CUSTOMER_CUST_ACCOUNT_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID := P_Quote_Line_Rec.END_CUSTOMER_CUST_ACCOUNT_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.END_CUSTOMER_CUST_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID := P_Quote_Line_Rec.END_CUSTOMER_CUST_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.END_CUSTOMER_PARTY_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_END_CUST_PTY_ID := P_Quote_Line_Rec.END_CUSTOMER_PARTY_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.END_CUSTOMER_PARTY_SITE_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID := P_Quote_Line_Rec.END_CUSTOMER_PARTY_SITE_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.CREDIT_CARD_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE := P_Line_Payment_Rec.CREDIT_CARD_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE IS NULL THEN
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE := P_Line_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.CREDIT_CARD_HOLDER_NAME IS NULL THEN
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME := P_Line_Payment_Rec.CREDIT_CARD_HOLDER_NAME;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.CUST_PO_NUMBER IS NULL THEN
          X_Qte_Line_Row_Rec.L_CUST_PO_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_CUST_PO_NUMBER := P_Line_Payment_Rec.CUST_PO_NUMBER;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.CUST_PO_LINE_NUMBER IS NULL THEN
          X_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER := P_Line_Payment_Rec.CUST_PO_LINE_NUMBER;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.PAYMENT_REF_NUMBER IS NULL THEN
          X_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER := P_Line_Payment_Rec.PAYMENT_REF_NUMBER;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.PAYMENT_TERM_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID := P_Line_Payment_Rec.PAYMENT_TERM_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Payment_Rec.PAYMENT_TYPE_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE := P_Line_Payment_Rec.PAYMENT_TYPE_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.REQUEST_DATE IS NULL THEN
          X_Qte_Line_Row_Rec.L_REQUEST_DATE := FND_API.G_MISS_DATE;
        ELSE
          X_Qte_Line_Row_Rec.L_REQUEST_DATE := P_Line_Shipment_Rec.REQUEST_DATE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_METHOD_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE := P_Line_Shipment_Rec.SHIP_METHOD_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIPMENT_PRIORITY_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE := P_Line_Shipment_Rec.SHIPMENT_PRIORITY_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIP_FROM_ORG_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID := FND_API.G_MISS_NUM;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID := P_Line_Shipment_Rec.SHIP_FROM_ORG_ID;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.DEMAND_CLASS_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE := P_Line_Shipment_Rec.DEMAND_CLASS_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.FOB_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_FOB_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_FOB_CODE := P_Line_Shipment_Rec.FOB_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.FREIGHT_TERMS_CODE IS NULL THEN
          X_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE := P_Line_Shipment_Rec.FREIGHT_TERMS_CODE;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.PACKING_INSTRUCTIONS IS NULL THEN
          X_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS := P_Line_Shipment_Rec.PACKING_INSTRUCTIONS;
        END IF;

        IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Line_Shipment_Rec.SHIPPING_INSTRUCTIONS IS NULL THEN
          X_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS := P_Line_Shipment_Rec.SHIPPING_INSTRUCTIONS;
        END IF;

	     X_Qte_Line_Row_Rec.L_APPLICATION_TYPE_CODE := P_Control_Rec.APPLICATION_TYPE_CODE;

          OPEN C_Line_Party_Type(P_Quote_Line_Rec.QUOTE_HEADER_ID);
          FETCH C_Line_Party_Type INTO X_Qte_Line_Row_Rec.L_QUOTE_CUSTOMER_TYPE;
          CLOSE C_Line_Party_Type;

          OPEN C_Product(P_Quote_line_Rec.inventory_item_id, P_Quote_Line_Rec.organization_id);
          FETCH C_Product INTO X_Qte_Line_Row_Rec.L_PRODUCT;
          CLOSE C_Product;

	-- Added to handle Inventory Item Id and Inventory Organization id
	-- Girish 9/30/2005

	IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.INVENTORY_ITEM_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_INVENTORY_ITEM_ID := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_INVENTORY_ITEM_ID := P_Quote_Line_Rec.INVENTORY_ITEM_ID;
        END IF;

	IF p_control_rec.defaulting_flow_code like 'CREATE%' AND
           P_Quote_Line_Rec.ORGANIZATION_ID IS NULL THEN
          X_Qte_Line_Row_Rec.L_ORGANIZATION_ID := FND_API.G_MISS_CHAR;
        ELSE
          X_Qte_Line_Row_Rec.L_ORGANIZATION_ID := P_Quote_Line_Rec.ORGANIZATION_ID;
        END IF;

	-- End

      END IF;

END Api_Rec_To_Row_Type;



PROCEDURE  ROW_TO_API_REC_TYPE
          (
           P_Entity_Code                      IN     VARCHAR2,
           P_Qte_Header_Row_Rec              IN     ASO_AK_Quote_Header_V%Rowtype,
           P_Qte_Opportunity_Row_Rec         IN     ASO_AK_Quote_Oppty_V%Rowtype,
           P_Qte_Line_Row_Rec                IN     ASO_AK_Quote_Line_V%Rowtype,
           X_Quote_Header_Rec            IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Qte_Header_Rec_Type,
           X_Header_Shipment_Rec         IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Shipment_Rec_Type,
           X_Header_Payment_Rec          IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Payment_Rec_Type,
           X_Quote_Line_Rec              IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Qte_Line_Rec_Type,
           X_Line_Shipment_Rec           IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Shipment_Rec_Type,
           X_Line_Payment_Rec            IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Payment_Rec_Type,
           X_HEADER_MISC_REC             IN OUT NOCOPY /* file.sql.39 change */      ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE,
           X_HEADER_TAX_DETAIL_REC       IN OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
           X_LINE_MISC_REC               IN OUT NOCOPY /* file.sql.39 change */      ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE,
           X_LINE_TAX_DETAIL_REC         IN OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE)

IS

BEGIN

      IF P_Entity_Code = 'QUOTE_HEADER' THEN
          X_Quote_Header_Rec.QUOTE_NAME :=  P_Qte_Header_Row_Rec.Q_QUOTE_NAME;
          X_Quote_Header_Rec.QUOTE_HEADER_ID := P_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID;
          X_Quote_Header_Rec.CUST_ACCOUNT_ID := P_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID;
          X_Quote_Header_Rec.QUOTE_EXPIRATION_DATE := P_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE;
          X_Quote_Header_Rec.QUOTE_STATUS_ID := P_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID;
          X_Quote_Header_Rec.ORG_ID := P_Qte_Header_Row_Rec.Q_ORG_ID;
          X_Quote_Header_Rec.CREATED_BY := P_Qte_Header_Row_Rec.Q_CREATED_BY;
          X_Quote_Header_Rec.ORDER_TYPE_ID := P_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID;
          X_Quote_Header_Rec.CONTRACT_ID := P_Qte_Header_Row_Rec.Q_CONTRACT_ID;
		X_Quote_Header_Rec.PRICE_LIST_ID := P_Qte_Header_Row_Rec.Q_PRICE_LIST_ID;
		X_Quote_Header_Rec.CURRENCY_CODE := P_Qte_Header_Row_Rec.Q_CURRENCY_CODE;
		X_Quote_Header_Rec.PRICE_FROZEN_DATE := P_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE;
		X_Quote_Header_Rec.CONTRACT_TEMPLATE_ID := P_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID;
		X_Quote_Header_Rec.RESOURCE_ID := P_Qte_Header_Row_Rec.Q_RESOURCE_ID;
		X_Quote_Header_Rec.RESOURCE_GRP_ID := P_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID;
		X_Quote_Header_Rec.SALES_CHANNEL_CODE :=  P_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE;
		X_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID := P_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID;
		X_Quote_Header_Rec.PARTY_ID := P_Qte_Header_Row_Rec.Q_PARTY_ID;
		X_Quote_Header_Rec.PHONE_ID := P_Qte_Header_Row_Rec.Q_PHONE_ID;
		X_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID := P_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID ;
		X_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID := P_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID;
		X_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID := P_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID;
		X_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID := P_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID;
		X_Quote_Header_Rec.INVOICE_TO_PARTY_ID := P_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID;
          X_Quote_Header_Rec.CUST_PARTY_ID := P_Qte_Header_Row_Rec.Q_CUST_PARTY_ID;
          X_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID := P_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID;
          X_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID := P_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID;
          X_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID := P_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID ;
          X_Quote_Header_Rec.END_CUSTOMER_PARTY_ID := P_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID;
          X_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG := P_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG ;
          X_Quote_Header_Rec.AUTOMATIC_TAX_FLAG := P_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG;
          X_Quote_Header_Rec.LAST_UPDATE_DATE := P_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE;
          X_Quote_Header_Rec.OBJECT_VERSION_NUMBER := P_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER ;
          X_Quote_Header_Rec.ATTRIBUTE_CATEGORY := P_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY;
          X_Quote_Header_Rec.ATTRIBUTE1 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE1;
          X_Quote_Header_Rec.ATTRIBUTE2 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE2;
          X_Quote_Header_Rec.ATTRIBUTE3 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE3;
          X_Quote_Header_Rec.ATTRIBUTE4 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE4;
          X_Quote_Header_Rec.ATTRIBUTE5 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE5;
          X_Quote_Header_Rec.ATTRIBUTE6 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE6;
          X_Quote_Header_Rec.ATTRIBUTE7 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE7;
          X_Quote_Header_Rec.ATTRIBUTE8 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE8;
          X_Quote_Header_Rec.ATTRIBUTE9 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE9;
          X_Quote_Header_Rec.ATTRIBUTE10 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE10;
          X_Quote_Header_Rec.ATTRIBUTE11 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE11;
          X_Quote_Header_Rec.ATTRIBUTE12 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE12;
          X_Quote_Header_Rec.ATTRIBUTE13 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE13;
          X_Quote_Header_Rec.ATTRIBUTE14 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE14;
          X_Quote_Header_Rec.ATTRIBUTE15 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE15;
          X_Quote_Header_Rec.ATTRIBUTE16 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE16;
          X_Quote_Header_Rec.ATTRIBUTE17 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE17;
          X_Quote_Header_Rec.ATTRIBUTE18 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE18;
          X_Quote_Header_Rec.ATTRIBUTE19 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE19;
          X_Quote_Header_Rec.ATTRIBUTE20 := P_Qte_Header_Row_Rec.Q_ATTRIBUTE20;
          X_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID :=P_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID;
          X_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID := P_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID;
          X_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID := P_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID;
          X_Header_Shipment_Rec.SHIP_TO_PARTY_ID := P_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID;
          X_Header_Payment_Rec.PAYMENT_TERM_ID := P_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID;
          X_Header_Payment_Rec.CUST_PO_NUMBER := P_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER ;
          X_Header_Payment_Rec.CREDIT_CARD_CODE := P_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE ;
          X_Header_Payment_Rec.PAYMENT_REF_NUMBER := P_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER ;
          X_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME := P_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME ;
          X_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE := P_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE ;
          X_Header_Payment_Rec.PAYMENT_TYPE_CODE := P_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE ;
          X_Header_Shipment_Rec.REQUEST_DATE_TYPE := P_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE ;
          X_Header_Shipment_Rec.REQUEST_DATE := P_Qte_Header_Row_Rec.Q_REQUEST_DATE ;
          X_Header_Shipment_Rec.SHIP_METHOD_CODE := P_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE;
          X_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE := P_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE;
          X_Header_Shipment_Rec.FREIGHT_TERMS_CODE := P_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE;
          X_Header_Shipment_Rec.FOB_CODE := P_Qte_Header_Row_Rec.Q_FOB_CODE;
          X_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS := P_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS;
          X_Header_Shipment_Rec.PACKING_INSTRUCTIONS := P_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS;
          X_Header_Shipment_Rec.DEMAND_CLASS_CODE := P_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE;

      ELSIF P_Entity_Code = 'QUOTE_OPPTY' THEN
          X_Quote_Header_Rec.QUOTE_NAME :=  P_Qte_Opportunity_Row_Rec.O_QUOTE_NAME;
          X_Quote_Header_Rec.QUOTE_HEADER_ID := P_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID;
          X_Quote_Header_Rec.CUST_ACCOUNT_ID := P_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID;
          X_Quote_Header_Rec.QUOTE_EXPIRATION_DATE := P_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE;
          X_Quote_Header_Rec.QUOTE_STATUS_ID := P_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID;
          X_Quote_Header_Rec.ORG_ID := P_Qte_Opportunity_Row_Rec.O_ORG_ID;
          X_Quote_Header_Rec.CREATED_BY := P_Qte_Opportunity_Row_Rec.O_CREATED_BY;
          X_Quote_Header_Rec.ORDER_TYPE_ID := P_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID;
          X_Quote_Header_Rec.CONTRACT_ID := P_Qte_Opportunity_Row_Rec.O_CONTRACT_ID;
		X_Quote_Header_Rec.PRICE_LIST_ID := P_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID;
		X_Quote_Header_Rec.CURRENCY_CODE := P_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE;
		X_Quote_Header_Rec.PRICE_FROZEN_DATE := P_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE;
		X_Quote_Header_Rec.CONTRACT_TEMPLATE_ID := P_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID;
		X_Quote_Header_Rec.RESOURCE_ID := P_Qte_Opportunity_Row_Rec.O_RESOURCE_ID;
		X_Quote_Header_Rec.RESOURCE_GRP_ID := P_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID;
		X_Quote_Header_Rec.SALES_CHANNEL_CODE :=  P_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE;
		X_Quote_Header_Rec.MARKETING_SOURCE_CODE_ID := P_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID;
		X_Quote_Header_Rec.PARTY_ID := P_Qte_Opportunity_Row_Rec.O_PARTY_ID;
		X_Quote_Header_Rec.PHONE_ID := P_Qte_Opportunity_Row_Rec.O_PHONE_ID;
		X_Quote_Header_Rec.SOLD_TO_PARTY_SITE_ID := P_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID ;
		X_Quote_Header_Rec.INVOICE_TO_CUST_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID;
		X_Quote_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID := P_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID;
		X_Quote_Header_Rec.INVOICE_TO_PARTY_SITE_ID := P_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID;
		X_Quote_Header_Rec.INVOICE_TO_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_INV_PTY_ID;
          X_Quote_Header_Rec.CUST_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID;
          X_Quote_Header_Rec.END_CUSTOMER_CUST_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID;
          X_Quote_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID := P_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID;
          X_Quote_Header_Rec.END_CUSTOMER_PARTY_SITE_ID := P_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID ;
          X_Quote_Header_Rec.END_CUSTOMER_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID;
          X_Quote_Header_Rec.AUTOMATIC_PRICE_FLAG := P_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG ;
          X_Quote_Header_Rec.AUTOMATIC_TAX_FLAG := P_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG;
          X_Quote_Header_Rec.LAST_UPDATE_DATE := P_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE;
          X_Quote_Header_Rec.OBJECT_VERSION_NUMBER := P_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER ;
          X_Quote_Header_Rec.ATTRIBUTE_CATEGORY := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY;
          X_Quote_Header_Rec.ATTRIBUTE1 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1;
          X_Quote_Header_Rec.ATTRIBUTE2 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2;
          X_Quote_Header_Rec.ATTRIBUTE3 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3;
          X_Quote_Header_Rec.ATTRIBUTE4 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4;
          X_Quote_Header_Rec.ATTRIBUTE5 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5;
          X_Quote_Header_Rec.ATTRIBUTE6 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6;
          X_Quote_Header_Rec.ATTRIBUTE7 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7;
          X_Quote_Header_Rec.ATTRIBUTE8 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8;
          X_Quote_Header_Rec.ATTRIBUTE9 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9;
          X_Quote_Header_Rec.ATTRIBUTE10 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10;
          X_Quote_Header_Rec.ATTRIBUTE11 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11;
          X_Quote_Header_Rec.ATTRIBUTE12 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12;
          X_Quote_Header_Rec.ATTRIBUTE13 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13;
          X_Quote_Header_Rec.ATTRIBUTE14 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14;
          X_Quote_Header_Rec.ATTRIBUTE15 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15;
          X_Quote_Header_Rec.ATTRIBUTE16 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16;
          X_Quote_Header_Rec.ATTRIBUTE17 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17;
          X_Quote_Header_Rec.ATTRIBUTE18 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18;
          X_Quote_Header_Rec.ATTRIBUTE19 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19;
          X_Quote_Header_Rec.ATTRIBUTE20 := P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20;
          X_Header_Shipment_Rec.SHIP_TO_CUST_PARTY_ID :=P_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID;
          X_Header_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID := P_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID;
          X_Header_Shipment_Rec.SHIP_TO_PARTY_SITE_ID := P_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID;
          X_Header_Shipment_Rec.SHIP_TO_PARTY_ID := P_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID;
          X_Header_Payment_Rec.PAYMENT_TERM_ID := P_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID;
          X_Header_Payment_Rec.CUST_PO_NUMBER := P_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER ;
          X_Header_Payment_Rec.CREDIT_CARD_CODE := P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE ;
          X_Header_Payment_Rec.PAYMENT_REF_NUMBER := P_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER ;
          X_Header_Payment_Rec.CREDIT_CARD_HOLDER_NAME := P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME ;
          X_Header_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE := P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE ;
          X_Header_Payment_Rec.PAYMENT_TYPE_CODE := P_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE ;
          X_Header_Shipment_Rec.REQUEST_DATE_TYPE := P_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE ;
          X_Header_Shipment_Rec.REQUEST_DATE := P_Qte_Opportunity_Row_Rec.O_REQUEST_DATE ;
          X_Header_Shipment_Rec.SHIP_METHOD_CODE := P_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE;
          X_Header_Shipment_Rec.SHIPMENT_PRIORITY_CODE := P_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE;
          X_Header_Shipment_Rec.FREIGHT_TERMS_CODE := P_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE;
          X_Header_Shipment_Rec.FOB_CODE := P_Qte_Opportunity_Row_Rec.O_FOB_CODE;
          X_Header_Shipment_Rec.SHIPPING_INSTRUCTIONS := P_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS;
          X_Header_Shipment_Rec.PACKING_INSTRUCTIONS := P_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS;
          X_Header_Shipment_Rec.DEMAND_CLASS_CODE := P_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE;

      ELSIF P_Entity_Code = 'QUOTE_LINE' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.ADD('X_Quote_Line_Rec.Inventory_Item_Id: '  || X_Quote_Line_Rec.Inventory_Item_Id,1,'N');
  aso_debug_pub.ADD('X_Quote_Line_Rec.uom_code: '  || X_Quote_Line_Rec.uom_code,1,'N');
END IF;

          X_Quote_Line_Rec.QUOTE_HEADER_ID := P_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID;
          X_Quote_Line_Rec.QUOTE_LINE_ID := P_Qte_Line_Row_Rec.L_QUOTE_LINE_ID;
          X_Quote_Line_Rec.LAST_UPDATE_DATE := P_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE;
          X_Quote_Line_Rec.OBJECT_VERSION_NUMBER := P_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER;
          X_Quote_Line_Rec.ATTRIBUTE_CATEGORY := P_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY;
          X_Quote_Line_Rec.ATTRIBUTE1 := P_Qte_Line_Row_Rec.L_ATTRIBUTE1;
          X_Quote_Line_Rec.ATTRIBUTE2 := P_Qte_Line_Row_Rec.L_ATTRIBUTE2;
          X_Quote_Line_Rec.ATTRIBUTE3 := P_Qte_Line_Row_Rec.L_ATTRIBUTE3;
          X_Quote_Line_Rec.ATTRIBUTE4 := P_Qte_Line_Row_Rec.L_ATTRIBUTE4;
          X_Quote_Line_Rec.ATTRIBUTE5 := P_Qte_Line_Row_Rec.L_ATTRIBUTE5;
          X_Quote_Line_Rec.ATTRIBUTE6 := P_Qte_Line_Row_Rec.L_ATTRIBUTE6;
          X_Quote_Line_Rec.ATTRIBUTE7 := P_Qte_Line_Row_Rec.L_ATTRIBUTE7;
          X_Quote_Line_Rec.ATTRIBUTE8 := P_Qte_Line_Row_Rec.L_ATTRIBUTE8;
          X_Quote_Line_Rec.ATTRIBUTE9 := P_Qte_Line_Row_Rec.L_ATTRIBUTE9;
          X_Quote_Line_Rec.ATTRIBUTE10 := P_Qte_Line_Row_Rec.L_ATTRIBUTE10;
          X_Quote_Line_Rec.ATTRIBUTE11 := P_Qte_Line_Row_Rec.L_ATTRIBUTE11;
          X_Quote_Line_Rec.ATTRIBUTE12 := P_Qte_Line_Row_Rec.L_ATTRIBUTE12;
          X_Quote_Line_Rec.ATTRIBUTE13 := P_Qte_Line_Row_Rec.L_ATTRIBUTE13;
          X_Quote_Line_Rec.ATTRIBUTE14 := P_Qte_Line_Row_Rec.L_ATTRIBUTE14;
          X_Quote_Line_Rec.ATTRIBUTE15 := P_Qte_Line_Row_Rec.L_ATTRIBUTE15;
          X_Quote_Line_Rec.ATTRIBUTE16 := P_Qte_Line_Row_Rec.L_ATTRIBUTE16;
          X_Quote_Line_Rec.ATTRIBUTE17 := P_Qte_Line_Row_Rec.L_ATTRIBUTE17;
          X_Quote_Line_Rec.ATTRIBUTE18 := P_Qte_Line_Row_Rec.L_ATTRIBUTE18;
          X_Quote_Line_Rec.ATTRIBUTE19 := P_Qte_Line_Row_Rec.L_ATTRIBUTE19;
          X_Quote_Line_Rec.ATTRIBUTE20 := P_Qte_Line_Row_Rec.L_ATTRIBUTE20;
          X_Quote_Line_Rec.CREATED_BY := P_Qte_Line_Row_Rec.L_CREATED_BY;
          X_Quote_Line_Rec.ORG_ID := P_Qte_Line_Row_Rec.L_ORG_ID;
          X_Quote_Line_Rec.ORDER_LINE_TYPE_ID := P_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID;
          X_Quote_Line_Rec.LINE_CATEGORY_CODE := P_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE;
          X_Quote_Line_Rec.CHARGE_PERIODICITY_CODE := P_Qte_Line_Row_Rec.L_PERIODICITY_CODE;
          X_Quote_Line_Rec.AGREEMENT_ID := P_Qte_Line_Row_Rec.L_AGREEMENT_ID;
          X_Quote_Line_Rec.PRICE_LIST_ID := P_Qte_Line_Row_Rec.L_PRICE_LIST_ID;
          X_Quote_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID := P_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID;
          X_Quote_Line_Rec.INVOICE_TO_CUST_PARTY_ID := P_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID;
          X_Quote_Line_Rec.INVOICE_TO_PARTY_ID := P_Qte_Line_Row_Rec.L_INV_TO_PTY_ID;
          X_Quote_Line_Rec.INVOICE_TO_PARTY_SITE_ID := P_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID;
          X_Quote_Line_Rec.END_CUSTOMER_CUST_ACCOUNT_ID := P_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID;
          X_Quote_Line_Rec.END_CUSTOMER_CUST_PARTY_ID := P_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID;
          X_Quote_Line_Rec.END_CUSTOMER_PARTY_ID := P_Qte_Line_Row_Rec.L_END_CUST_PTY_ID;
          X_Quote_Line_Rec.END_CUSTOMER_PARTY_SITE_ID := P_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID;

          IF X_Line_Payment_Rec.Operation_Code IS NULL OR X_Line_Payment_Rec.Operation_Code = FND_API.G_MISS_CHAR THEN
              X_Line_Payment_Rec.Operation_Code := 'CREATE';
              X_Line_Payment_Rec.qte_line_index := 1;
          ELSIF X_Line_Payment_Rec.Operation_Code = 'CREATE' THEN
              X_Line_Payment_Rec.qte_line_index := 1;
          END IF;

          X_Line_Payment_Rec.CREDIT_CARD_CODE := P_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE;
          X_Line_Payment_Rec.CREDIT_CARD_EXPIRATION_DATE := P_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE;
          X_Line_Payment_Rec.CREDIT_CARD_HOLDER_NAME := P_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME;
          X_Line_Payment_Rec.CUST_PO_NUMBER := P_Qte_Line_Row_Rec.L_CUST_PO_NUMBER;
          X_Line_Payment_Rec.CUST_PO_LINE_NUMBER := P_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER;
          X_Line_Payment_Rec.PAYMENT_REF_NUMBER := P_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER;
          X_Line_Payment_Rec.PAYMENT_TERM_ID := P_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID;
          X_Line_Payment_Rec.PAYMENT_TYPE_CODE := P_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE;

          IF X_Line_Shipment_Rec.Operation_Code IS NULL OR X_Line_Shipment_Rec.Operation_Code = FND_API.G_MISS_CHAR THEN
              X_Line_Shipment_Rec.Operation_Code := 'CREATE';
              X_Line_Shipment_Rec.qte_line_index := 1;
          ELSIF X_Line_Shipment_Rec.Operation_Code = 'CREATE' THEN
              X_Line_Shipment_Rec.qte_line_index := 1;
          END IF;

          X_Line_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID := P_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID;
          X_Line_Shipment_Rec.SHIP_TO_CUST_PARTY_ID := P_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID;
          X_Line_Shipment_Rec.SHIP_TO_PARTY_ID := P_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID;
          X_Line_Shipment_Rec.SHIP_TO_PARTY_SITE_ID := P_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID;
          X_Line_Shipment_Rec.REQUEST_DATE := P_Qte_Line_Row_Rec.L_REQUEST_DATE;
          X_Line_Shipment_Rec.SHIP_METHOD_CODE := P_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE;
          X_Line_Shipment_Rec.SHIPMENT_PRIORITY_CODE := P_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE;
          X_Line_Shipment_Rec.SHIP_FROM_ORG_ID := P_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID;
          X_Line_Shipment_Rec.DEMAND_CLASS_CODE := P_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE;
          X_Line_Shipment_Rec.FOB_CODE := P_Qte_Line_Row_Rec.L_FOB_CODE;
          X_Line_Shipment_Rec.FREIGHT_TERMS_CODE := P_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE;
          X_Line_Shipment_Rec.PACKING_INSTRUCTIONS := P_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS;
          X_Line_Shipment_Rec.SHIPPING_INSTRUCTIONS := P_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS;

      END IF;

END ROW_TO_API_REC_TYPE;



PROCEDURE  Initialize_Row_Type
         (
           P_Entity_Code                      IN     VARCHAR2,
           P_Qte_Header_Row_Rec              IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Header_V%Rowtype,
           P_Qte_Opportunity_Row_Rec         IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Oppty_V%Rowtype,
           P_Qte_Line_Row_Rec                IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Line_V%Rowtype)

IS

BEGIN

      IF P_Entity_Code = 'QUOTE_HEADER' THEN
          P_Qte_Header_Row_Rec.Q_QUOTE_NAME := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE := FND_API.G_MISS_DATE;
          P_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_ORG_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CREATED_BY := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CONTRACT_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_PRICE_LIST_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CURRENCY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE := FND_API.G_MISS_DATE;
          P_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_RESOURCE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_PHONE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM ;
          P_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CUST_PARTY_ID := FND_API.G_MISS_NUM ;
          P_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
          P_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
          P_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE ;
          P_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE := FND_API.G_MISS_CHAR ;
          P_Qte_Header_Row_Rec.Q_REQUEST_DATE := FND_API.G_MISS_DATE;
          P_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_FOB_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_APPLICATION_TYPE_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Header_Row_Rec.Q_QUOTE_CUSTOMER_TYPE := FND_API.G_MISS_CHAR;

      ELSIF P_Entity_Code = 'QUOTE_OPPTY' THEN
          P_Qte_Opportunity_Row_Rec.O_QUOTE_NAME := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE := FND_API.G_MISS_DATE;
          P_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_ORG_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CREATED_BY := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CONTRACT_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE := FND_API.G_MISS_DATE;
          P_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_RESOURCE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_PHONE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM ;
          P_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_INV_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID := FND_API.G_MISS_NUM ;
          P_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
          P_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE ;
          P_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE := FND_API.G_MISS_CHAR ;
          P_Qte_Opportunity_Row_Rec.O_REQUEST_DATE := FND_API.G_MISS_DATE;
          P_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_FOB_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_APPLICATION_TYPE_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_QUOTE_TO_CUST_TYPE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_CURRENCY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_CHANNEL_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_QUOTE_NAME := FND_API.G_MISS_CHAR;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_CUST_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_MKTG_SRC_CD_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_PTY_ST_ID := FND_API.G_MISS_NUM;
          P_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_TO_CONT_ID := FND_API.G_MISS_NUM;

      ELSIF P_Entity_Code = 'QUOTE_LINE' THEN
          P_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID :=  FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_QUOTE_LINE_ID :=  FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE :=  FND_API.G_MISS_DATE;
          P_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER :=  FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE16 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE17 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE18 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE19 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_ATTRIBUTE20 := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_CREATED_BY := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_ORG_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_PERIODICITY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_AGREEMENT_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_PRICE_LIST_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_INV_TO_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_END_CUST_PTY_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE := FND_API.G_MISS_DATE;
          P_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_CUST_PO_NUMBER := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_REQUEST_DATE := FND_API.G_MISS_DATE;
          P_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID := FND_API.G_MISS_NUM;
          P_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_FOB_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_APPLICATION_TYPE_CODE := FND_API.G_MISS_CHAR;
          P_Qte_Line_Row_Rec.L_QUOTE_CUSTOMER_TYPE := FND_API.G_MISS_CHAR;

      END IF;

END Initialize_Row_Type;


END ASO_DEFAULTING_UTIL;

/
