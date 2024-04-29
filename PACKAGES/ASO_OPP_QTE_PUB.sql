--------------------------------------------------------
--  DDL for Package ASO_OPP_QTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_OPP_QTE_PUB" AUTHID CURRENT_USER AS
/* $Header: asopopqs.pls 120.3 2005/11/01 14:54:30 skulkarn ship $ */

-- Start of Comments
-- Package name : ASO_OPP_QTE_PUB
-- Purpose      : API to create quote from opportunity
-- End of Comments


TYPE OPP_QTE_IN_REC_TYPE IS RECORD
(
    OPPORTUNITY_ID                NUMBER := FND_API.G_MISS_NUM,            -- Lead ID
    QUOTE_NUMBER                  NUMBER := FND_API.G_MISS_NUM,            -- Quote Number
    QUOTE_NAME                    VARCHAR2(240) := FND_API.G_MISS_CHAR,     -- Quote Name
    CUST_ACCOUNT_ID               NUMBER := FND_API.G_MISS_NUM,            -- Sold_To Customer (Party) Account
    RESOURCE_ID                   NUMBER := FND_API.G_MISS_NUM,            -- Primary Salesperson
    SOLD_TO_CONTACT_ID            NUMBER := FND_API.G_MISS_NUM,            -- Sold_To Contact
    SOLD_TO_PARTY_SITE_ID         NUMBER := FND_API.G_MISS_NUM,            -- Sold_To Address
    PRICE_LIST_ID                 NUMBER := FND_API.G_MISS_NUM,            -- Price List
    RESOURCE_GRP_ID               NUMBER := FND_API.G_MISS_NUM,            -- Primary Sales Group
    CHANNEL_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,     -- Sales Channel
    ORDER_TYPE_ID                 NUMBER := FND_API.G_MISS_NUM,            -- Order Type
    AGREEMENT_ID                  NUMBER := FND_API.G_MISS_NUM,            -- Contract
    CONTRACT_TEMPLATE_ID          NUMBER := FND_API.G_MISS_NUM,            -- Contract Template
    CONTRACT_TEMPLATE_MAJOR_VER   NUMBER := FND_API.G_MISS_NUM,            -- Contract Template Major Version
    CURRENCY_CODE                 VARCHAR2(15) := FND_API.G_MISS_CHAR,     -- Currency Code
    MARKETING_SOURCE_CODE_ID      NUMBER := FND_API.G_MISS_NUM,             -- Marketing Source Code
    QUOTE_EXPIRATION_DATE         DATE   := FND_API.G_MISS_DATE,            -- Quote Expiration Date
    CUST_PARTY_ID                 NUMBER := FND_API.G_MISS_NUM,
    PRICING_STATUS_INDICATOR      VARCHAR2(1) := FND_API.G_MISS_CHAR,
    TAX_STATUS_INDICATOR          VARCHAR2(1) := FND_API.G_MISS_CHAR,
    PRICE_UPDATED_DATE            DATE :=  FND_API.G_MISS_DATE,
    TAX_UPDATED_DATE              DATE :=  FND_API.G_MISS_DATE,
    ORG_ID		          NUMBER:= FND_API.G_MISS_NUM               --Yogeshwar (MOAC)
);

TYPE OPP_QTE_IN_TBL_TYPE IS TABLE OF OPP_QTE_IN_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_OPP_QTE_IN_REC             OPP_QTE_IN_REC_TYPE;
G_MISS_OPP_QTE_IN_TBL             OPP_QTE_IN_TBL_TYPE;


TYPE OPP_QTE_OUT_REC_TYPE IS RECORD
(
    QUOTE_HEADER_ID               NUMBER := FND_API.G_MISS_NUM,
    QUOTE_NUMBER                  NUMBER := FND_API.G_MISS_NUM,            -- Quote Number
    RELATED_OBJECT_ID             NUMBER := FND_API.G_MISS_NUM,
    CUST_ACCOUNT_ID               NUMBER := FND_API.G_MISS_NUM,
    PARTY_ID                      NUMBER := FND_API.G_MISS_NUM,
    CURRENCY_CODE                 VARCHAR2(15) := FND_API.G_MISS_CHAR
);

TYPE OPP_QTE_OUT_TBL_TYPE IS TABLE OF OPP_QTE_OUT_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_OPP_QTE_OUT_REC            OPP_QTE_OUT_REC_TYPE;
G_MISS_OPP_QTE_OUT_TBL            OPP_QTE_OUT_TBL_TYPE;


PROCEDURE Create_Qte_Opportunity(
	P_API_VERSION_NUMBER		IN	NUMBER,
	P_INIT_MSG_LIST			IN	VARCHAR2                             := FND_API.G_FALSE,
	P_COMMIT				IN	VARCHAR2                             := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		IN	NUMBER                               := FND_API.G_VALID_LEVEL_FULL,
	P_SOURCE_CODE			IN	VARCHAR2,
	P_QUOTE_HEADER_REC		IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec,
	P_HEADER_PAYMENT_REC		IN	ASO_QUOTE_PUB.Payment_Rec_Type      := ASO_QUOTE_PUB.G_MISS_Payment_REC,
	P_HEADER_SHIPMENT_REC		IN	ASO_QUOTE_PUB.Shipment_Rec_Type     := ASO_QUOTE_PUB.G_MISS_Shipment_REC,
	P_HEADER_TAX_DETAIL_REC		IN	ASO_QUOTE_PUB.Tax_Detail_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Tax_Detail_Rec,
	P_TEMPLATE_TBL			IN    ASO_QUOTE_PUB.TEMPLATE_TBL_TYPE     := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
	P_OPP_QTE_IN_REC             	IN	OPP_QTE_IN_REC_TYPE,
	P_CONTROL_REC                	IN	ASO_QUOTE_PUB.Control_Rec_Type       := ASO_QUOTE_PUB.G_MISS_Control_Rec,
	X_OPP_QTE_OUT_REC             OUT NOCOPY /* file.sql.39 change */ OPP_QTE_OUT_REC_TYPE,
	X_RETURN_STATUS		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	X_MSG_COUNT			 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	X_MSG_DATA			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


FUNCTION Validate_Item(
    p_qte_header_rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_inventory_item_id      IN   NUMBER,
    p_organization_id        IN   NUMBER,
    p_quantity               IN   NUMBER,
    p_uom_code               IN   VARCHAR2
) RETURN BOOLEAN;


PROCEDURE Set_Copy_Flags
(
    p_object_id              IN   NUMBER,
    x_copy_notes_flag        OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_copy_task_flag         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_copy_att_flag          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


Procedure Address_Validation(
	p_party_site_id     IN     Number,
	p_use_type          IN     VARCHAR2,
	x_valid             OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	X_RETURN_STATUS     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	X_MSG_COUNT         OUT NOCOPY /* file.sql.39 change */    NUMBER,
	X_MSG_DATA          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
);


END; -- ASO_OPP_QTE_PUB


 

/
