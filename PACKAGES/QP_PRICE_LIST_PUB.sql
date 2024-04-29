--------------------------------------------------------
--  DDL for Package QP_PRICE_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_LIST_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPPRLS.pls 120.5 2006/02/22 10:26:47 shulin ship $ */
/*#
 * This package consists of entities to set up price lists.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Price List Setup
 * @rep:category BUSINESS_ENTITY QP_PRICE_LIST
 */

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
,   automatic_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   comments                      VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   currency_code                 VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   discount_lines_flag           VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   freight_terms_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   gsa_indicator                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_type_code                VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   prorate_flag                  VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   rounding_factor               NUMBER         := FND_API.G_MISS_NUM
,   ship_method_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   terms_id                      NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   version_no                    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   active_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   mobile_download               VARCHAR2(1)    := FND_API.G_MISS_CHAR -- mkarya for bug 1944882
,   currency_header_id            NUMBER         := FND_API.G_MISS_NUM -- Multi-Currency SunilPandey
,   pte_code                      VARCHAR2(30)   := FND_API.G_MISS_CHAR -- Attribute Manager Giri
,   list_source_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR --  Blanket Sales Order, arraghav
,   orig_system_header_ref        VARCHAR2(50)   := FND_API.G_MISS_CHAR --  Blanket Sales Order, arraghav
,   global_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR -- Pricing Security , gtippire
,   source_system_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   shareable_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   sold_to_org_id                NUMBER         := FND_API.G_MISS_NUM
,   locked_from_list_header_id    NUMBER         := FND_API.G_MISS_NUM
--added for MOAC support
,   org_id                        NUMBER         := FND_API.G_MISS_NUM
);

TYPE Price_List_Tbl_Type IS TABLE OF Price_List_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List value record type

TYPE Price_List_Val_Rec_Type IS RECORD
(   automatic                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   currency                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount_lines                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   freight_terms                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_type                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   prorate                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   ship_method                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   terms                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   currency_header               VARCHAR2(240)  := FND_API.G_MISS_CHAR -- Multi-Currency SunilPandey
,   pte                           VARCHAR2(240)  := FND_API.G_MISS_CHAR -- Attribute Manager Giri
,   list_source_code              VARCHAR2(240)   := FND_API.G_MISS_CHAR
-- Blanket Sales Order, arraghav
,   orig_system_header_ref        VARCHAR2(240)   := FND_API.G_MISS_CHAR
-- Blanket Sales Order, arraghav
);

TYPE Price_List_Val_Tbl_Type IS TABLE OF Price_List_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List_Line record type

TYPE Price_List_Line_Rec_Type IS RECORD
(   accrual_qty                   NUMBER         := FND_API.G_MISS_NUM
,   accrual_uom_code              VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   arithmetic_operator           VARCHAR2(30)   := FND_API.G_MISS_CHAR
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
,   automatic_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   base_qty                      NUMBER         := FND_API.G_MISS_NUM
,   base_uom_code                 VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   comments                      VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   effective_period_uom          VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   estim_accrual_rate            NUMBER         := FND_API.G_MISS_NUM
,   generate_using_formula_id     NUMBER         := FND_API.G_MISS_NUM
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   list_line_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_price                    NUMBER         := FND_API.G_MISS_NUM
,   modifier_level_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   number_effective_periods      NUMBER         := FND_API.G_MISS_NUM
,   operand                       NUMBER         := FND_API.G_MISS_NUM
,   organization_id               NUMBER         := FND_API.G_MISS_NUM
,   override_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   percent_price                 NUMBER         := FND_API.G_MISS_NUM
,   price_break_type_code         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   price_by_formula_id           NUMBER         := FND_API.G_MISS_NUM
,   primary_uom_flag              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   print_on_invoice_flag         VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   rebate_trxn_type_code         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   related_item_id               NUMBER         := FND_API.G_MISS_NUM
,   relationship_type_id          NUMBER         := FND_API.G_MISS_NUM
,   reprice_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   revision                      VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   revision_date                 DATE           := FND_API.G_MISS_DATE
,   revision_reason_code          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   substitution_attribute        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   substitution_context          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   substitution_value            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   rltd_modifier_id              NUMBER         := FND_API.G_MISS_NUM
,   from_rltd_modifier_id         NUMBER         := FND_API.G_MISS_NUM
,   to_rltd_modifier_id           NUMBER         := FND_API.G_MISS_NUM
,   rltd_modifier_group_no        NUMBER         := FND_API.G_MISS_NUM
,   rltd_modifier_grp_type        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_precedence            NUMBER         := FND_API.G_MISS_NUM
,   PRICE_BREAK_HEADER_index      NUMBER         := FND_API.G_MISS_NUM
,   list_line_no                  VARCHAR2(30)   := FND_API.G_MISS_CHAR --  bug 4199398
,   qualification_ind             NUMBER         := FND_API.G_MISS_NUM --Euro Bug 2138996.
,   recurring_value               NUMBER         := FND_API.G_MISS_NUM -- block pricing
,   customer_item_id              NUMBER         := FND_API.G_MISS_NUM
,   break_uom_code                VARCHAR2(3)    := FND_API.G_MISS_CHAR -- OKS proration
,   break_uom_context             VARCHAR2(30)   := FND_API.G_MISS_CHAR -- OKS proration
,   break_uom_attribute           VARCHAR2(30)   := FND_API.G_MISS_CHAR -- OKS proration
,   continuous_price_break_flag   VARCHAR2(1)    := FND_API.G_MISS_CHAR -- Continuous Price Breaks
);

TYPE Price_List_Line_Tbl_Type IS TABLE OF Price_List_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_List_Line value record type

TYPE Price_List_Line_Val_Rec_Type IS RECORD
(   accrual_uom                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   automatic                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   base_uom                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   generate_using_formula        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   inventory_item                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line_type                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   modifier_level                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   organization                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   override                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_break_type              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_by_formula              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   primary_uom                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   print_on_invoice              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   rebate_transaction_type       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   related_item                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   relationship_type             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   reprice                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   revision_reason               VARCHAR2(240)  := FND_API.G_MISS_CHAR
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
,   pricing_attr_value_from_number       NUMBER  := FND_API.G_MISS_NUM
,   pricing_attr_value_to_number         NUMBER  := FND_API.G_MISS_NUM
,   qualification_ind                    NUMBER  := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   PRICE_LIST_LINE_index         NUMBER         := FND_API.G_MISS_NUM
,   from_rltd_modifier_id         NUMBER         := FND_API.G_MISS_NUM
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   product_attribute_datatype    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_datatype    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   pricing_phase_id              NUMBER         := FND_API.G_MISS_NUM
);

TYPE Pricing_Attr_Tbl_Type IS TABLE OF Pricing_Attr_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Pricing_Attr value record type

TYPE Pricing_Attr_Val_Rec_Type IS RECORD
(   accumulate                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   excluder                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_uom                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute_desc        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attr_value_from_desc  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attr_value_to_desc    VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Pricing_Attr_Val_Tbl_Type IS TABLE OF Pricing_Attr_Val_Rec_Type
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
G_MISS_QUALIFIERS_REC         QP_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
G_MISS_QUALIFIERS_VAL_REC     QP_Qualifier_Rules_Pub.Qualifiers_Val_Rec_Type;
G_MISS_QUALIFIERS_TBL         QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
G_MISS_QUALIFIERS_VAL_TBL     QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
G_MISS_PRICING_ATTR_REC       Pricing_Attr_Rec_Type;
G_MISS_PRICING_ATTR_VAL_REC   Pricing_Attr_Val_Rec_Type;
G_MISS_PRICING_ATTR_TBL       Pricing_Attr_Tbl_Type;
G_MISS_PRICING_ATTR_VAL_TBL   Pricing_Attr_Val_Tbl_Type;

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

/*#
 * Use this API to create, update, and delete price lists.
 *
 * @param p_api_version_number the api version number
 * @param p_init_msg_list true or false if there is an initial message list
 * @param p_return_values true or false if there are return values
 * @param p_commit true or false if the modifier should be committed
 * @param x_return_status the return status
 * @param x_msg_count the message count
 * @param x_msg_data the message data
 * @param p_PRICE_LIST_rec the input record corresponding to the columns in the
 *        price list header tables QP_LIST_HEADERS_B and
 *        QP_LIST_HEADERS_TL
 * @param p_PRICE_LIST_val_rec the input record containing values that store the
 *        meaning of id or code columns in the price list
 *        header table QP_LIST_HEADERS_B
 * @param p_PRICE_LIST_LINE_tbl the input table for the price list line
 *        definitions
 * @param p_PRICE_LIST_LINE_val_tbl the input table for the price list line
 *        values
 * @param p_QUALIFIERS_tbl the input table used to attach multiple qualifiers
 *        either at the header level (modifier list) or at the
 *        line level (modifier) by giving multiple qualifier
 *        definitions
 * @param p_QUALIFIERS_val_tbl the input table for the qualifier values
 * @param p_PRICING_ATTR_tbl the input table used to attach multiple pricing
 *        attributes to modifier lines by giving multiple
 *        pricing attribute definitions
 * @param p_PRICING_ATTR_val_tbl the input table for the pricing attribute
 *        definition values
 * @param x_PRICE_LIST_rec the output record corresponding to the columns in the
 *        price list header tables QP_LIST_HEADERS_B and
 *        QP_LIST_HEADERS_TL
 * @param x_PRICE_LIST_val_rec the output record containing values that store the
 *        meaning of id or code columns in the price list
 *        header table QP_LIST_HEADERS_B
 * @param x_PRICE_LIST_LINE_tbl the output table for the price list line
 *        definitions
 * @param x_PRICE_LIST_LINE_val_tbl the output table for the price list line
 *        values
 * @param x_QUALIFIERS_tbl the output table for the qualifier definition
 * @param x_QUALIFIERS_val_tbl the output table for the qualifier values
 * @param x_PRICING_ATTR_tbl the output table for the pricing attribute
 *        definition
 * @param x_PRICING_ATTR_val_tbl the output table for the pricing attribute
 *        values
 *
 * @rep:displayname Process Price List
 */
PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
,   p_check_duplicate_lines         IN  VARCHAR2 DEFAULT NULL  --5018856, 5024801, 5024919

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
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
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
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
);

END QP_Price_List_PUB;

 

/
