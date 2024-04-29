--------------------------------------------------------
--  DDL for Package OE_PRICE_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_LIST_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPPRLS.pls 120.0 2005/06/02 00:21:04 appldev noship $ */

--  Price_List record type

TYPE Price_List_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   comments                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   currency_code                 VARCHAR2(15)   := FND_API.G_MISS_CHAR
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   freight_terms_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list_id                 NUMBER         := FND_API.G_MISS_NUM
,   pricing_contract_id             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   rounding_factor               NUMBER         := FND_API.G_MISS_NUM
,   secondary_price_list_id       NUMBER         := FND_API.G_MISS_NUM
,   ship_method_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   terms_id                      NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   tp_attribute1		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute2		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute3		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute4		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute5		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute6		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute7		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute8		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute9		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute10		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute11		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute12		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute13		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute14		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute15		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute_category	  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   currency_header_id            NUMBER         := FND_API.G_MISS_NUM -- Multi-Currency SunilPandey
);

TYPE Price_List_Tbl_Type IS TABLE OF Price_List_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List value record type

TYPE Price_List_Val_Rec_Type IS RECORD
(   currency                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   freight_terms                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   secondary_price_list          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   ship_method                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   terms                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Price_List_Val_Tbl_Type IS TABLE OF Price_List_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List_Line record type

TYPE Price_List_Line_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   comments                      VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   customer_item_id              NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_price                    NUMBER         := FND_API.G_MISS_NUM
,   method_code                   VARCHAR2(4)    := FND_API.G_MISS_CHAR
,   price_list_id                 NUMBER         := FND_API.G_MISS_NUM
,   price_list_line_id            NUMBER         := FND_API.G_MISS_NUM
,   pricing_attribute1            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute10           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute11           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute12           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute13           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute14           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute15           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute2            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute3            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute4            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute5            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute6            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute7            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute8            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute9            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_context               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_rule_id               NUMBER         := FND_API.G_MISS_NUM
,   primary                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   reprice_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   revision                      VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   revision_date                 DATE           := FND_API.G_MISS_DATE
,   revision_reason_code          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   unit_code                     VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   tp_attribute1		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute2		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute3		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute4		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute5		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute6		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute7		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute8		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute9		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute10		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute11		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute12		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute13		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute14		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute15		  VARCHAR2(240)	 := FND_API.G_MISS_CHAR
,   tp_attribute_category	  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   method_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   price_break_high              NUMBER         := FND_API.G_MISS_NUM
,   price_break_low               NUMBER         := FND_API.G_MISS_NUM
,   price_break_parent_line       NUMBER         := FND_API.G_MISS_NUM
,   list_line_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   price_break_type_code         VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Price_List_Line_Tbl_Type IS TABLE OF Price_List_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List_Line value record type

TYPE Price_List_Line_Val_Rec_Type IS RECORD
(   customer_item                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   inventory_item                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   method                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list_line               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_rule                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   reprice                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   revision_reason               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   unit                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Price_List_Line_Val_Tbl_Type IS TABLE OF Price_List_Line_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Pricing_Attr record type

TYPE Pricing_Attr_Rec_Type IS RECORD
(   accumulate_flag               VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute_grouping_no         NUMBER         := FND_API.G_MISS_NUM
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   excluder_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   pricing_attribute             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_id          NUMBER         := FND_API.G_MISS_NUM
,   pricing_attr_value_from       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attr_value_to         VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_attribute             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_attribute_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_attr_value            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_uom_code              VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   PRICE_LIST_LINE_index         NUMBER         := FND_API.G_MISS_NUM
);

TYPE Pricing_Attr_Tbl_Type IS TABLE OF Pricing_Attr_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_PRICE_LIST_REC         Price_List_Rec_Type;
G_MISS_PRICE_LIST_VAL_REC     Price_List_Val_Rec_Type;
G_MISS_PRICE_LIST_TBL         Price_List_Tbl_Type;
G_MISS_PRICE_LIST_VAL_TBL     Price_List_Val_Tbl_Type;
G_MISS_PRICE_LIST_LINE_REC    Price_List_Line_Rec_Type;
G_MISS_PRICE_LIST_LINE_VAL_REC Price_List_Line_Val_Rec_Type;
G_MISS_PRICE_LIST_LINE_TBL    Price_List_Line_Tbl_Type;
G_MISS_PRICE_LIST_LINE_VAL_TBL Price_List_Line_Val_Tbl_Type;
G_MISS_PRICING_ATTR_TBL       Pricing_Attr_Tbl_Type;

--  Start of Comments
--  API name    Process_Price_List
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
/*
PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_List
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_List
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_name                          IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_price_list_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_list                    IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
);
*/

END OE_Price_List_PUB;

 

/
