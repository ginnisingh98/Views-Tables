--------------------------------------------------------
--  DDL for Package IBE_QUOTE_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_MISC_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVQMIS.pls 120.6.12010000.3 2013/05/03 08:55:25 nsatyava ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Quote_Misc_pvt';

SAVE_NORMAL           CONSTANT NUMBER := 0;
SAVE_ADDTOCART        CONSTANT NUMBER := 1;
SAVE_EXPRESSORDER     CONSTANT NUMBER := 2;
SAVE_PAYMENT_ONLY     CONSTANT NUMBER := 3;
END_WORKING           CONSTANT NUMBER := 4;
SALES_ASSISTANCE      CONSTANT NUMBER := 5;
PLACE_ORDER           CONSTANT NUMBER := 6;
UPDATE_EXPRESSORDER   CONSTANT NUMBER := 7;
OP_DELETE_CART        CONSTANT NUMBER := 8;
OP_DUPLICATE_CART     CONSTANT NUMBER := 9;

FUNCTION get_multi_svc_profile return VARCHAR2;

FUNCTION is_quote_usable(
         p_quote_header_id  IN NUMBER,
         p_party_id         IN NUMBER,
         p_cust_account_id  IN NUMBER) return varchar2;
-- Start of comments
--    API name   : Get_Active_Quote
--    Type       : Private.
--    Function   :
--    Pre-reqs   : None.
--    Parameters :
--    Version    : Current version	x1.0
--    Notes      : Note text
--
-- End of comments
FUNCTION Get_Active_Quote_ID
(
   p_party_id        IN NUMBER,
   p_cust_account_id IN NUMBER
--   p_only_max        IN BOOLEAN := TRUE
) RETURN NUMBER;


PROCEDURE Get_Number_Of_Lines
(
   p_party_id        IN  NUMBER,
   p_cust_account_id IN  NUMBER,
   x_number_of_lines OUT NOCOPY NUMBER
);


--wli
FUNCTION get_Quote_Status(
  p_quote_header_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION getLineIndexFromLineId(
  p_quote_line_id           IN NUMBER
  ,p_qte_line_tbl           IN ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE
) RETURN NUMBER;


FUNCTION getQuoteLastUpdateDate(
  p_quote_header_id         IN NUMBER
) RETURN DATE;


FUNCTION getLinePrcAttrTbl(
  p_quote_line_id             IN  NUMBER
) RETURN    ASO_QUOTE_PUB.PRICE_ATTRIBUTES_TBL_TYPE;

FUNCTION getLineAttrExtTbl(
  p_quote_line_id             IN  NUMBER
) RETURN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;


FUNCTION getLineDetailTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;


FUNCTION getLineRelationshipTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;

FUNCTION getLinePrcAdjTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type;

FUNCTION getHdrPrcAdjTbl(
  p_quote_hdr_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type;

--Added for PRG bug fix,4094994
FUNCTION getAllLinesPrcAdjTbl(
  p_quote_hdr_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type;


FUNCTION getLinePrcAdjRelTbl(
  p_price_adjustment_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

FUNCTION getPrcAdjIndexFromPrcAdjId(
  p_price_adjustment_id     IN NUMBER
  ,p_Price_Adjustment_tbl           IN aso_quote_pub.Price_Adj_Tbl_Type
) RETURN NUMBER;

FUNCTION getLineTbl(
  p_quote_header_Id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE;


FUNCTION getLineRec(
  p_qte_line_id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;


FUNCTION getHeaderRec(
  p_quote_header_Id            IN  NUMBER
) RETURN ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE;


FUNCTION getHeaderPaymentTbl(
  p_quote_header_Id            IN  NUMBER
) RETURN ASO_QUOTE_PUB.PAYMENT_TBL_TYPE;


FUNCTION getShareePrivilege(
  p_quote_header_Id            IN  NUMBER
  ,p_sharee_number             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION getUserType(
  p_partyId  IN Varchar2
) RETURN VARCHAR2;

PROCEDURE ValidateQuoteLastUpdateDate(
  p_api_version_number      IN NUMBER
  ,p_quote_header_id        IN NUMBER
  ,p_last_update_date       IN DATE
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
);


PROCEDURE getQuoteOwner(
  p_api_version_number      IN  NUMBER
--  ,p_init_msg_list          IN  VARCHAR2   := FND_API.G_FALSE
--  ,p_commit                 IN  VARCHAR2    := FND_API.G_FALSE
  ,p_quote_header_Id	    IN 	NUMBER

  ,x_party_id		    OUT NOCOPY	NUMBER
  ,x_cust_account_id	    OUT NOCOPY NUMBER
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Shared_Quote(
   p_api_version_number IN  NUMBER                         ,
   p_quote_password     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number       IN  NUMBER                         ,
   p_quote_version      IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE                           ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2
);

--- direct entry
PROCEDURE Load_Item_IDs(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_cust_id               IN  NUMBER                     ,
   p_cust_item_number_tbl  IN  jtf_varchar2_table_100     ,
   p_organization_id       IN  NUMBER                     ,
   p_minisite_id	   IN  NUMBER			  ,
   x_inventory_item_id_tbl OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
);

--- direct entry cross reference bug 2641510
PROCEDURE Load_Item_IDs_for_crossRef(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_crossRef_type_tbl  IN  jtf_varchar2_table_100     ,
   p_crossRef_number_tbl  IN  jtf_varchar2_table_100     ,
   p_organization_id       IN  NUMBER                     ,
   x_inventory_item_id_tbl OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
);

---converting ShoppingList, saved cart, Quote to Active shopping cart
PROCEDURE Check_Item_IDs(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_cust_id               IN  NUMBER                     ,
   p_organization_id       IN  NUMBER                     ,
   p_minisite_id	   IN  NUMBER			  ,
   x_inventory_item_id_tbl IN OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
);


procedure get_load_errors(
   X_reason_code      OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   p_api_version      IN  NUMBER   := 1.0             ,
   p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE  ,
   p_commit           IN  VARCHAR2 := FND_API.G_FALSE ,
   x_return_status    OUT NOCOPY VARCHAR2             ,
   x_msg_count        OUT NOCOPY NUMBER               ,
   x_msg_data         OUT NOCOPY VARCHAR2             ,
   P_quote_header_id  IN  number := FND_API.G_MISS_NUM,
   P_Load_type        IN  number := FND_API.G_MISS_NUM,
   P_quote_number     IN  number := FND_API.G_MISS_NUM,
   P_quote_version    IN  number := FND_API.G_MISS_NUM,
   P_party_id         IN  number := FND_API.G_MISS_NUM,
   P_cust_account_id  IN  number := FND_API.G_MISS_NUM,
   P_retrieval_number IN  number := FND_API.G_MISS_NUM,
   P_share_type       IN  number := -1,
   p_access_level     IN number  := 0
);


PROCEDURE Update_Config_Item_Lines(
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER  ,
   x_msg_data             OUT NOCOPY VARCHAR2,
   px_qte_line_dtl_tbl IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
);

procedure Validate_Items(
   x_item_exists	    OUT NOCOPY 	jtf_number_Table,
   p_cust_account_id	IN	NUMBER,
   p_minisite_id	    IN	NUMBER,
   p_merchant_item_ids	IN 	JTF_NUMBER_TABLE,
   p_org_id		        IN 	NUMBER
);

PROCEDURE Get_Included_Warranties(
  p_api_version_number              IN  NUMBER := 1,
  p_init_msg_list                   IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                          IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2,
  p_organization_id                 IN  NUMBER := NULL,
  p_product_item_id                 IN  NUMBER,
  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
);

PROCEDURE Get_Available_Services(
  p_api_version_number              IN  NUMBER := 1,
  p_init_msg_list                   IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                          IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2,
  p_product_item_id                 IN  NUMBER,
  p_customer_id                     IN  NUMBER,
  p_product_revision                IN  VARCHAR2,
  p_request_date                    IN  DATE,
  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
);

Procedure Duplicate_Line(
  p_api_version_number        IN  NUMBER
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status            OUT NOCOPY VARCHAR2
  ,X_Msg_Count                OUT NOCOPY NUMBER
  ,X_Msg_Data                 OUT NOCOPY VARCHAR2
  ,p_quote_header_id          IN  NUMBER
  ,p_qte_line_id              IN  NUMBER
  ,x_qte_line_tbl             IN OUT NOCOPY ASO_Quote_Pub.qte_line_tbl_type
  ,x_qte_line_dtl_tbl         IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type
  ,x_line_attr_ext_tbl        IN OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type
  ,x_line_rltship_tbl         IN OUT NOCOPY ASO_Quote_Pub.Line_Rltship_tbl_Type
  ,x_ln_price_attributes_tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_ln_price_adj_tbl         IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
);

FUNCTION getHdrPrcAdjNonPRGTbl (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

Procedure Split_Line(
   p_api_version_number     IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
  ,p_quote_header_id        IN  NUMBER
  ,p_qte_line_id            IN  NUMBER
  ,p_quantities             IN  jtf_number_table
  ,p_last_update_date       IN OUT NOCOPY DATE
  ,p_party_id               IN NUMBER := FND_API.G_MISS_NUM
  ,p_cust_account_id        IN NUMBER := FND_API.G_MISS_NUM
  ,p_quote_retrieval_number IN NUMBER := FND_API.G_MISS_NUM
  ,p_minisite_id            IN NUMBER := FND_API.G_MISS_NUM
  ,p_validate_user          IN VARCHAR2 := FND_API.G_FALSE
 );

PROCEDURE validate_quote(
  p_quote_header_id               IN  NUMBER
 ,p_save_type                     IN  NUMBER := FND_API.G_MISS_NUM
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2);

PROCEDURE Validate_User_Update(
  p_api_version_number         IN NUMBER   := 1.0
 ,p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
 ,p_quote_header_id            IN NUMBER
 ,p_party_id                   IN NUMBER   := FND_API.G_MISS_NUM
 ,p_cust_account_id            IN NUMBER   := FND_API.G_MISS_NUM
 ,p_quote_retrieval_number     IN NUMBER   := FND_API.G_MISS_NUM
 ,p_validate_user              IN VARCHAR2 := FND_API.G_FALSE
 ,p_privilege_type_code        IN VARCHAR2 := 'F'
 ,p_save_type                  IN NUMBER := FND_API.G_MISS_NUM
 ,p_last_update_date           IN DATE     := FND_API.G_MISS_DATE
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2);

PROCEDURE upgrade_recipient_row(
  p_party_id         IN NUMBER,
  p_cust_account_id  IN NUMBER,
  p_retrieval_number IN NUMBER,
  p_quote_header_id  IN NUMBER,
  x_valid_flag       OUT NOCOPY VARCHAR2);


PROCEDURE Log_Environment_Info (
   p_quote_header_id      in number := null
);

FUNCTION Get_party_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		)
RETURN VARCHAR2;

PROCEDURE Add_Attachment(
  p_api_version_number    IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_category_id          IN  VARCHAR2
  ,p_document_description IN  VARCHAR2
  ,p_datatype_id          IN  VARCHAR2
  ,p_text                 IN  LONG
  ,p_file_name            IN  VARCHAR2
  ,p_url                  IN  VARCHAR2
  ,p_function_name        IN  VARCHAR2 := null
  ,p_quote_header_id      IN  NUMBER
  ,p_media_id             IN  NUMBER
  ,p_party_id             IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_cust_account_id      IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_retrieval_number     IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_validate_user        IN  VARCHAR2 := FND_API.G_FALSE
  ,p_last_update_date     IN  DATE     := FND_API.G_MISS_DATE
  ,p_save_type            IN  NUMBER   := FND_API.G_MISS_NUM
  ,x_last_update_date     OUT NOCOPY   DATE
  ,x_return_status        OUT NOCOPY   VARCHAR2
  ,x_msg_count            OUT NOCOPY   NUMBER
  ,x_msg_data             OUT NOCOPY   VARCHAR2
);

PROCEDURE Delete_Attachment(
   p_api_version_number   IN  NUMBER  := 1.0
  ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_quote_header_id      IN  NUMBER
  ,p_quote_attachment_ids IN  JTF_VARCHAR2_TABLE_100
  ,p_last_update_date     IN  DATE     := FND_API.G_MISS_DATE
  ,p_party_id             IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_cust_account_id      IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_retrieval_number     IN  NUMBER   := FND_API.G_MISS_NUM
  ,x_last_update_date     OUT NOCOPY   DATE
  ,x_return_status        OUT NOCOPY   VARCHAR2
  ,x_msg_count            OUT NOCOPY   NUMBER
  ,x_msg_data             OUT NOCOPY   VARCHAR2
);

Function get_aso_quote_status (p_quote_header_id NUMBER )RETURN varchar2 ;

PROCEDURE get_primary_file_id(p_quote_id IN NUMBER,
                              x_file_id OUT NOCOPY NUMBER);

END IBE_Quote_Misc_pvt;

/
