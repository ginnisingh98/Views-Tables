--------------------------------------------------------
--  DDL for Package IBE_QUOTE_SAVESHARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_SAVESHARE_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVQSSS.pls 120.2 2005/07/15 10:03:10 appldev ship $ */
-- Start of Comments
-- Package name     : IBE_QUOTE_SAVESHARE_pvt
-- Purpose	    :
-- NOTE 	    :

-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE QUOTE_ACCESS_Rec_Type IS RECORD
(
       QUOTE_SHAREE_ID               NUMBER         := FND_API.G_MISS_NUM,
       CREATION_DATE                 DATE           := FND_API.G_MISS_DATE,
       CREATED_BY                    NUMBER         := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE              DATE           := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY               NUMBER         := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN             NUMBER         := FND_API.G_MISS_NUM,
       REQUEST_ID                    NUMBER         := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID        NUMBER         := FND_API.G_MISS_NUM,
       PROGRAM_ID                    NUMBER         := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE           DATE           := FND_API.G_MISS_DATE,
       OBJECT_VERSION_NUMBER         NUMBER         := FND_API.G_MISS_NUM,
       QUOTE_HEADER_ID               NUMBER         := FND_API.G_MISS_NUM,
       QUOTE_SHAREE_NUMBER           NUMBER         := FND_API.G_MISS_NUM,
       EMAIL_CONTACT_ADDRESS         VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       UPDATE_PRIVILEGE_TYPE_CODE    VARCHAR2(100)  := FND_API.G_MISS_CHAR,
       --MANNAMRA: NEW COLUMNS ADDED: 08/26/2002
       SECURITY_GROUP_ID             NUMBER         := FND_API.G_MISS_NUM,
       PARTY_ID                      NUMBER         := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID               NUMBER         := FND_API.G_MISS_NUM,
       START_DATE_ACTIVE             DATE           := FND_API.G_MISS_DATE,
       END_DATE_ACTIVE               DATE           := FND_API.G_MISS_DATE,
       RECIPIENT_NAME                VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       OPERATION_CODE                VARCHAR2(100)  := FND_API.G_MISS_CHAR,
       CONTACT_POINT_ID              NUMBER         := FND_API.G_MISS_NUM,
       --END: NEW COLUMNS
       --MANNAMRA: NEW COLUMNS ADDED: 06/30/2003
       /*Adding shared_by_partyid to this record structure to identify who actually shared the cart.
       This is necessary to display the "shared by" name in notifications.Because it's possible to have multiple
       admins on a shared cart, the recipients on a shared cart could have been added by different admins
       or the owner.The necessity to match the recipient with appropriate "shared_by" requires us to add the
       shared_by_partyid to this record structure.We determine the shared_by_partyid by looking at the
       "created by" column in sh_quote_access tbl*/

       NOTIFY_FLAG                   VARCHAR2(2)    := FND_API.G_TRUE,
       SHARED_BY_PARTY_ID            NUMBER         := FND_API.G_MISS_NUM
       --END: NEW COLUMNS
);

G_MISS_QUOTE_ACCESS_REC       QUOTE_ACCESS_Rec_Type;
TYPE QUOTE_ACCESS_Tbl_Type    IS TABLE OF QUOTE_ACCESS_Rec_Type
                                        INDEX BY BINARY_INTEGER;
G_MISS_QUOTE_ACCESS_TBL       QUOTE_ACCESS_Tbl_Type;

--MANNAMRA: NEW ACTIVE_CARTS_REC_TYPE ADDED: 08/26/2002
TYPE ACTIVE_CARTS_Rec_Type is RECORD
(
ACTIVE_QUOTE_ID            NUMBER :=FND_API.G_MISS_NUM,
PROGRAM_APPLICATION_ID     NUMBER :=FND_API.G_MISS_NUM,
PROGRAM_ID                 NUMBER :=FND_API.G_MISS_NUM,
PROGRAM_UPDATE_DATE        DATE   :=FND_API.G_MISS_DATE,
OBJECT_VERSION_NUMBER      NUMBER :=FND_API.G_MISS_NUM,
CREATED_BY                 NUMBER :=FND_API.G_MISS_NUM,
CREATION_DATE              DATE   :=FND_API.G_MISS_DATE,
LAST_UPDATED_BY            NUMBER :=FND_API.G_MISS_NUM,
LAST_UPDATE_DATE           DATE   :=FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN          NUMBER :=FND_API.G_MISS_NUM,
QUOTE_HEADER_ID            NUMBER :=FND_API.G_MISS_NUM,
PARTY_ID                   NUMBER :=FND_API.G_MISS_NUM,
CUST_ACCOUNT_ID            NUMBER :=FND_API.G_MISS_NUM,
ORG_ID                     NUMBER :=FND_API.G_MISS_NUM
);
G_MISS_ACTIVE_CART_REC_TYPE   ACTIVE_CARTS_Rec_Type;
TYPE ACTIVE_CART_Tbl_Type     Is table of
                              ACTIVE_CARTS_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_ACTIVE_CART_tbl_TYPE   ACTIVE_CART_tbl_TYPE;

--END:NEW ACTIVE_CARTS_REC_TYPE

-- API NAME:  SAVEASANDSHARE
-- IN PARAMETERS (non-standard)
--   1. need p_original_quote_header_id to get items related information
--      like: lines, det_lines, rel_lines, line_ext_attribute
--   2. need p_quote_name, p_quote_source_type, p_party_id, p_cust_account_id
--      p_quote_password for create a new  quote header
--   3. need p_url, p_sharee_email_address, p_sharee_privilege_type
--      for create a new sharee record and send email to sharees
--   4. need p_currency_code, p_price_list_id and
--      control_rec
--      (p_pricing_request_type, p_header_pricing_event, p_line_pricing_event,
--       p_cal_tax_flag, p_cal_freight_charge_flag)
--      to decide price related issues
-- OUT PARAMETERS (non-standard)
--   x_new_quote_Header_id

PROCEDURE SaveAsAndShare(
   p_api_version_number     IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
  ,p_from_quote_header_id   IN  NUMBER
  ,p_from_last_update_date  IN  DATE
  ,p_copy_only_header       IN  VARCHAR2 := FND_API.G_FALSE
  ,p_to_Control_Rec         IN  ASO_Quote_Pub.Control_Rec_Type
                                   := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_to_Qte_Header_Rec      IN  ASO_Quote_Pub.Qte_Header_Rec_Type
  ,p_to_hd_Shipment_rec     IN  ASO_Quote_Pub.Shipment_rec_Type
                                   := ASO_Quote_Pub.G_MISS_SHIPMENT_rec
  ,p_url                    IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_sharee_email_address   IN  jtf_varchar2_table_2000 := NULL
  ,p_sharee_privilege_type  IN  jtf_varchar2_table_100  := NULL
  ,p_comments               IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_quote_retrieval_number IN  NUMBER := FND_API.G_MISS_NUM
  ,p_minisite_id	    IN  NUMBER := FND_API.G_MISS_NUM
  ,p_validate_user          IN  VARCHAR2  := FND_API.G_FALSE
  ,x_to_quote_header_id     OUT NOCOPY NUMBER
  ,x_to_last_update_date    OUT NOCOPY DATE
);

-- API NAME:  APPENDTOORREPLACEANDSHARE
-- Append
-- IN PARAMETERS (non-standard)
--    1. need p_original_quote_header_id to get items related information
--       like: lines, det_lines, rel_lines, line_ext_attribute
--    2. need p_appendto_quote_header_id
--    3. need p_new_quote_password for new password.
--    4. need p_url, p_sharee_email_address, p_sharee_privilege_type
--       for create a new sharee record and send email to sharees
--    5. need p_currency_code, p_price_list_id and
--       control_rec
--       (p_pricing_request_type, p_header_pricing_event,
--       p_line_pricing_event, p_cal_tax_flag, p_cal_freight_charge_flag)
--       to decide price related issues
--    6. need p_increaseversion to decide if make a copy of appendto quote or not
--    7. may need p_combinesameitem to decide
--       if combine save inventory item to save line or not
-- OUT PARAMETERs (non-standard)
--    x_new_quote_Header_id


-- Replace
-- IN PARAMETERS (non-standard)
--    1. need p_original_quote_header_id to get items related information
--       like: lines, det_lines, rel_lines, line_ext_attribute
--    2. need p_appendto_quote_header_id
--    3. need p_new_quote_password for new password.
--    4. need p_url, p_sharee_email_address, p_sharee_privilege_type
--       for create a new sharee record and send email to sharees
--    5. need p_currency_code, p_price_list_id and
--       control_rec
--       (p_pricing_request_type, p_header_pricing_event,
--       p_line_pricing_event, p_cal_tax_flag, p_cal_freight_charge_flag)
--       to decide price related issues
--    6. need p_increaseversion to decide if make a copy of appendto quote or not
--    7. 8/12/02: added more ASO API parameters to be passed to the IBE_Quote_Save_pvt.save
-- OUT PARAMETERs (non-standard)
--    x_new_quote_Header_id

PROCEDURE AppendToReplaceShare(
   p_api_version_number       IN  NUMBER                         ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_mode                     IN  VARCHAR2 := 'APPENDTO'         ,
   p_combinesameitem          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_increaseversion          IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_original_quote_header_id IN  NUMBER                         ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_rep_app_quote_header_id  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_new_quote_password       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_url                      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sharee_email_address     IN  jtf_varchar2_table_2000 := NULL,
   p_sharee_privilege_type    IN  jtf_varchar2_table_100  := NULL,
   p_currency_code            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id	      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec              IN  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   p_comments                 IN VARCHAR2 := FND_API.G_MISS_CHAR ,
   p_rep_app_invTo_partySiteId IN  NUMBER := FND_API.G_MISS_NUM  ,
   p_Hd_Price_Attributes_Tbl  IN  ASO_Quote_Pub.Price_Attributes_Tbl_Type := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl,
   p_Hd_Payment_Tbl           IN  ASO_Quote_Pub.Payment_Tbl_Type          := ASO_Quote_Pub.G_MISS_PAYMENT_TBL,
   p_Hd_Shipment_Tbl          IN  ASO_Quote_Pub.Shipment_Tbl_Type         := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL,
   p_Hd_Freight_Charge_Tbl    IN  ASO_Quote_Pub.Freight_Charge_Tbl_Type   := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl,
   p_Hd_Tax_Detail_Tbl        IN  ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE       := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl,
   p_Price_Adjustment_Tbl     IN  ASO_Quote_Pub.Price_Adj_Tbl_Type        := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl,
   p_Price_Adj_Attr_Tbl       IN  ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type   := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl,
   p_Price_Adj_Rltship_Tbl    IN  ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type:= ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl,
   p_quote_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_party_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_cust_account_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_validate_user            IN  VARCHAR2   := FND_API.G_FALSE,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   x_quote_header_id          OUT NOCOPY NUMBER                         ,
   x_last_update_date         OUT NOCOPY DATE
);

-- API Name:  ShareQuote
-- IN PARAMETERS (non-standard)
--    1. need p_quote_header_id to share with
--    2. need p_url, p_sharee_email_address, p_sharee_privilege_type
--       for create a new sharee record and send email to sharees
-- OUT PARAMETERs (non-standard)
--      no
PROCEDURE ShareQuote(
   p_api_version_number    IN  NUMBER   := 1                  ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status         OUT NOCOPY VARCHAR2                       ,
   x_msg_count             OUT NOCOPY NUMBER                         ,
   x_msg_data              OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id       IN  NUMBER                         ,
   p_url                   IN  VARCHAR2                       ,
   p_sharee_email_address  IN  JTF_VARCHAR2_TABLE_2000 := NULL,
   p_sharee_privilege_type IN  JTF_VARCHAR2_TABLE_100  := NULL,
   p_comments              IN  VARCHAR2 := FND_API.G_MISS_CHAR
);


Procedure ActivateQuote(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_increaseversion    IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE
);


PROCEDURE RetrieveShareQuote(
   p_api_version_number     IN  NUMBER                         ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status          OUT NOCOPY VARCHAR2                       ,
   x_msg_count              OUT NOCOPY NUMBER                         ,
   x_msg_data               OUT NOCOPY VARCHAR2                       ,
   p_quote_password         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number           IN  NUMBER                         ,
   p_quote_version          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_number          IN  NUMBER                         ,
   p_sharee_party_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_cust_account_id IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_currency_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id   	    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec            IN  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   p_minisite_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_quote_header_id        OUT NOCOPY NUMBER                         ,
   x_last_update_date       OUT NOCOPY DATE                           ,
   x_privilege_type_code    OUT NOCOPY VARCHAR2
);


PROCEDURE mergeActiveQuote (
   p_api_version_number IN  NUMBER                         ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_mode               IN  VARCHAR2 := 'MERGE'            ,
   p_combinesameitem    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id           IN  NUMBER                         ,
   p_cust_account_id    IN  NUMBER                         ,
   p_quote_source_code  IN  VARCHAR2 := 'IStore Account'   ,
   p_minisite_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_currency_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id	    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec        IN  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE                           ,
   x_retrieval_number   OUT NOCOPY NUMBER
);

PROCEDURE SaveSharee (
  P_Api_Version_Number      IN   NUMBER
  ,p_Init_Msg_List          IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Commit		            IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Quote_Header_id        IN   NUMBER
  ,p_emailAddress           IN   varchar2
  ,p_privilegeType          IN   varchar2
  ,p_recip_party_id         IN   NUMBER   := FND_API.G_MISS_NUM
  ,p_recip_cust_account_id  IN   NUMBER   := FND_API.G_MISS_NUM
  ,x_qte_access_rec	        OUT NOCOPY  IBE_QUOTE_saveshare_pvt.QUOTE_ACCESS_Rec_Type
  ,X_Return_Status          OUT NOCOPY  VARCHAR2
  ,X_Msg_Count 		        OUT NOCOPY  NUMBER
  ,X_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE EmailSharee(
  p_Api_Version_Number         IN   NUMBER
  ,p_Init_Msg_List             IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Commit                    IN   VARCHAR2 := FND_API.G_FALSE

  ,p_Quote_Header_id           IN   NUMBER
  ,p_emailAddress              IN   varchar2
  ,p_privilegeType             IN   varchar2

  ,p_url                       IN   varchar2
  ,p_qte_access_rec            IN   IBE_QUOTE_saveshare_pvt.QUOTE_ACCESS_Rec_Type
  ,p_comments                  IN VARCHAR2 := FND_API.G_MISS_CHAR
  ,X_Return_Status             OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                 OUT NOCOPY  NUMBER
  ,X_Msg_Data                  OUT NOCOPY  VARCHAR2
);

PROCEDURE GenerateShareeNumber
(
  p_quote_header_id IN  NUMBER,
  p_recip_id        IN  NUMBER,
  x_sharee_number   OUT NOCOPY NUMBER
);

Procedure Copy_Lines(
  p_api_version_number       IN  NUMBER
  ,p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                  IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status           OUT NOCOPY VARCHAR2
  ,X_Msg_Count               OUT NOCOPY NUMBER
  ,X_Msg_Data                OUT NOCOPY VARCHAR2

  ,p_from_quote_header_id    IN  NUMBER
  ,p_to_quote_header_id      IN  NUMBER
  ,p_mode                    IN VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_qte_line_tbl            OUT NOCOPY ASO_Quote_Pub.qte_line_tbl_type
  ,x_qte_line_dtl_tbl        OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type
  ,x_line_attr_ext_tbl       OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type
  ,x_line_rltship_tbl        OUT NOCOPY ASO_Quote_Pub.Line_Rltship_tbl_Type
  ,x_ln_price_attributes_tbl OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Price_Adjustment_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl   IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
);

END IBE_QUOTE_SAVESHARE_pvt;

 

/
