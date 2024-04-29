--------------------------------------------------------
--  DDL for Package OZF_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRICELIST_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvplts.pls 120.1 2005/08/17 17:56:39 appldev ship $ */

-- start of comment
-- History
--    19-MAY-2001 julou  modified   added primary_uom_flag to Price_List_Line_Rec_Type
--    22-Oct-2002 Added Currency_header_id for multi currency support
--    09-SEP-2004 julou bug 3863693: expose flex field
-- end of comment

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_pricelist_PVT';

TYPE OZF_Price_List_Rec_Type IS RECORD
(   currency_code                 VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   active_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   PRICE_LIST_ATTRIBUTE_ID       NUMBER := FND_API.G_MISS_NUM
,   USER_STATUS_ID                NUMBER := FND_API.G_MISS_NUM
,   CUSTOM_SETUP_ID               NUMBER := FND_API.G_MISS_NUM
,   STATUS_CODE                   VARCHAR2(30) := FND_API.G_MISS_CHAR
,   OWNER_ID                      NUMBER := FND_API.G_MISS_NUM
,   QP_LIST_HEADER_ID             NUMBER := FND_API.G_MISS_NUM
,   OBJECT_VERSION_NUMBER         NUMBER := FND_API.G_MISS_NUM
,   STATUS_DATE                   DATE := FND_API.G_MISS_DATE
,   WF_ITEM_KEY                   VARCHAR2(100) := FND_API.G_MISS_CHAR
,   currency_header_id            NUMBER        := FND_API.G_MISS_NUM
,   CONTEXT                       VARCHAR2(30)   := Fnd_Api.g_miss_char
,   ATTRIBUTE1                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE2                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE3                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE4                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE5                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE6                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE7                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE8                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE9                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE10                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE11                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE12                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE13                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE14                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE15                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   global_flag                   VARCHAR2(1)    := Fnd_Api.g_miss_char
,   org_id                        NUMBER         := FND_API.G_MISS_NUM
);

TYPE Qualifiers_Rec_Type IS RECORD
(   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   excluder_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   qualifier_attribute           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_attr_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attr_value_to       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_context             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_datatype            VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   qualifier_grouping_no         NUMBER         := FND_API.G_MISS_NUM
,   qualifier_id                  NUMBER         := FND_API.G_MISS_NUM
,   qualifier_precedence          NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   CONTEXT                       VARCHAR2(30)   := Fnd_Api.g_miss_char
,   ATTRIBUTE1                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE2                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE3                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE4                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE5                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE6                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE7                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE8                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE9                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE10                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE11                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE12                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE13                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE14                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE15                   VARCHAR2(240)  := Fnd_Api.g_miss_char
);

TYPE Qualifiers_Tbl_Type IS TABLE OF Qualifiers_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Price_List_Line_Rec_Type IS RECORD
(   arithmetic_operator           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   list_price                    NUMBER         := FND_API.G_MISS_NUM
,   operand                       NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   primary_uom_flag              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   product_precedence            NUMBER         := FND_API.G_MISS_NUM
,   static_formula_id             NUMBER         := FND_API.G_MISS_NUM
,   dynamic_formula_id            NUMBER         := FND_API.G_MISS_NUM
,   jtf_note_id                   NUMBER         := FND_API.G_MISS_NUM
,   comments                      VARCHAR2(2000) := fnd_api.g_miss_char
,   object_version_number         NUMBER         := FND_API.G_MISS_NUM
,   CONTEXT                       VARCHAR2(30)   := Fnd_Api.g_miss_char
,   ATTRIBUTE1                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE2                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE3                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE4                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE5                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE6                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE7                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE8                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE9                    VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE10                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE11                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE12                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE13                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE14                   VARCHAR2(240)  := Fnd_Api.g_miss_char
,   ATTRIBUTE15                   VARCHAR2(240)  := Fnd_Api.g_miss_char
);

TYPE Price_List_Line_Tbl_Type IS TABLE OF Price_List_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Pricing_Attr_Rec_Type IS RECORD
(   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   pricing_attribute             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_id          NUMBER         := FND_API.G_MISS_NUM
,   pricing_attr_value_from       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attr_value_to         VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_attribute             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_attribute_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_attr_value            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_uom_code              VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   PRICE_LIST_LINE_index         NUMBER         := FND_API.G_MISS_NUM
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
);

TYPE Pricing_Attr_Tbl_Type IS TABLE OF Pricing_Attr_Rec_Type
    INDEX BY BINARY_INTEGER;

PROCEDURE process_price_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_price_list_rec    IN  ozf_price_list_rec_type,
   p_price_list_line_tbl IN  price_list_line_tbl_type,
   p_pricing_attr_tbl  IN  pricing_attr_tbl_type,
   p_qualifiers_tbl    IN  QUALIFIERS_TBL_TYPE,
   x_list_header_id   OUT NOCOPY  NUMBER,
   x_error_source     OUT NOCOPY  VARCHAR2,
   x_error_location   OUT NOCOPY  NUMBER
);

PROCEDURE move_segments (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_price_list_id     IN  NUMBER
  );

FUNCTION get_product_name
  (   p_type        IN     VARCHAR2,
      p_prod_value  IN     NUMBER
  ) RETURN VARCHAR2;
FUNCTION get_currency_header_name
  (   p_currency_header_id IN     NUMBER
  ) RETURN VARCHAR2;

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE add_inventory_item(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_org_inv_item_id   IN  NUMBER,
   p_new_inv_item_id   IN num_tbl_type
);
END OZF_PRICELIST_PVT;

 

/
