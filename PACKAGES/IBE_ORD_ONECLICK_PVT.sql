--------------------------------------------------------
--  DDL for Package IBE_ORD_ONECLICK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ORD_ONECLICK_PVT" AUTHID CURRENT_USER AS
  /* $Header: IBEVO1CS.pls 120.2.12010000.2 2011/01/31 06:39:03 scnagara ship $ */

UPDATE_EXPRESSORDER      CONSTANT NUMBER := 7;

function Get_Credit_Card_Type(
    p_Credit_Card_Number NUMBER
) RETURN VARCHAR2;

Procedure get_express_items_settings(
           x_qte_header_rec   IN OUT NOCOPY aso_quote_pub.Qte_Header_Rec_Type
          ,p_flag             IN     VARCHAR2 := 'ITEMS'
          ,x_payment_tbl      IN OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type

          ,x_hd_shipment_tbl  IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type

          ,x_hd_tax_dtl_tbl   IN OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type);

procedure Get_Settings(
	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level	IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,

	p_party_id  	IN 	NUMBER := NULL,
	p_acct_id  	IN 	NUMBER := NULL,

	x_OBJECT_VERSION_NUMBER	OUT NOCOPY	NUMBER,
	x_ONECLICK_ID     	OUT NOCOPY	NUMBER,
	x_ENABLED_FLAG		OUT NOCOPY	VARCHAR2,
	x_FREIGHT_CODE		OUT NOCOPY	VARCHAR2,
	x_PAYMENT_ID	 	OUT NOCOPY	NUMBER,
	x_BILL_PTYSITE_ID  	OUT NOCOPY	NUMBER,
	x_SHIP_PTYSITE_ID 	OUT NOCOPY	NUMBER,
	x_LAST_UPDATE_DATE 	OUT NOCOPY	DATE,
	x_EMAIL_ADDRESS	 	OUT NOCOPY	VARCHAR2
);

procedure Save_Settings(
	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level	IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,

	p_party_id  	IN 	NUMBER := NULL,
	p_acct_id  	IN 	NUMBER := NULL,

	p_OBJECT_VERSION_NUMBER	IN	NUMBER := FND_API.G_MISS_NUM,
	p_ENABLED_FLAG		IN	VARCHAR2 :=  'N',
	p_FREIGHT_CODE		IN	VARCHAR2 :=  FND_API.G_MISS_CHAR,
	p_PAYMENT_ID	 	IN	NUMBER :=  FND_API.G_MISS_NUM,
	p_BILL_PTYSITE_ID  	IN	NUMBER :=  FND_API.G_MISS_NUM,
	p_SHIP_PTYSITE_ID 	IN	NUMBER :=  FND_API.G_MISS_NUM
);

procedure Express_Buy_Order(
	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level	IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,

	-- identification
	p_party_id 	IN	NUMBER,
	p_acct_id 	IN	NUMBER,
	p_retrieval_num IN	NUMBER := FND_API.g_miss_num, -- optional, only if recipient is expressing a cart

	-- common pricing parameters
	p_currency_code	IN	VARCHAR2 := FND_API.g_miss_char,
	p_price_list_id	IN	NUMBER := FND_API.g_miss_num,
	p_price_req_type IN	VARCHAR2 := FND_API.g_miss_char,
	p_incart_event	IN	VARCHAR2 := FND_API.g_miss_char,
	p_incart_line_event IN	VARCHAR2 := FND_API.g_miss_char,

	-- flag to drive behavior
	-- (values: 'ITEMS', 'CART', 'LISTS', 'LIST_LINES')
	p_flag		IN 	VARCHAR2 := FND_API.g_miss_char,

	-- for express checkout of a shopping cart
	p_cart_id	IN	NUMBER := FND_API.g_miss_num,
        p_minisite_id   IN	NUMBER := FND_API.g_miss_num, -- for stop sharing notification

	-- for express checkout of a list of shopping lists
	p_list_ids	IN	JTF_NUMBER_TABLE,
	p_list_ovns 	IN	JTF_NUMBER_TABLE,

	-- for express checkout of a list of shopping list lines
	p_list_line_ids	IN	JTF_NUMBER_TABLE,
	p_list_line_ovns IN	JTF_NUMBER_TABLE,

	-- for express checkout of a list of items (usually from catalog)
	p_item_ids 	IN	JTF_NUMBER_TABLE,
	p_qtys 		IN	JTF_NUMBER_TABLE,
	p_org_ids 	IN	JTF_NUMBER_TABLE,
	p_uom_codes	IN	JTF_VARCHAR2_TABLE_100,

	-- return the quote header id
	x_new_cart_id	OUT NOCOPY	NUMBER,

    -- TimeStamp check
    p_last_update_date           IN DATE     := FND_API.G_MISS_DATE,
    x_last_update_date         OUT NOCOPY  DATE,
    p_price_mode VARCHAR2 := 'ENTIRE_QUOTE'
);

Procedure Update_Settings(
    p_api_version      IN     NUMBER,
    p_init_msg_list    IN    VARCHAR2 := FND_API.g_false,
    p_commit           IN    VARCHAR2 := FND_API.g_false,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2,
    p_party_id         IN     NUMBER := NULL,
    p_acct_id          IN     NUMBER := NULL,
    p_assignment_id    IN     NUMBER := NULL);

End IBE_ORD_ONECLICK_PVT;

/
