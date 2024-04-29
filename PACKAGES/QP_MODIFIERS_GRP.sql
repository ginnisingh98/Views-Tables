--------------------------------------------------------
--  DDL for Package QP_MODIFIERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIERS_GRP" AUTHID CURRENT_USER AS
/* $Header: QPXGMLSS.pls 120.1 2005/06/10 00:40:19 appldev  $ */

--  Modifier_List record type

/*
TYPE Modifier_List_Rec_Type IS RECORD
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
,   source_system_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   active_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   parent_list_header_id         NUMBER         := FND_API.G_MISS_NUM
,   start_date_active_first       DATE           := FND_API.G_MISS_DATE
,   end_date_active_first         DATE           := FND_API.G_MISS_DATE
,   active_date_first_type        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active_second      DATE           := FND_API.G_MISS_DATE
,   end_date_active_second        DATE           := FND_API.G_MISS_DATE
,   active_date_second_type       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   ask_for_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   version_no                    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);


TYPE Modifier_List_Tbl_Type IS TABLE OF Modifier_List_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Modifier_List value record type

TYPE Modifier_List_Val_Rec_Type IS RECORD
(   automatic                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   currency                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount_lines                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   freight_terms                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_type                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   prorate                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   ship_method                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   terms                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Modifier_List_Val_Tbl_Type IS TABLE OF Modifier_List_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Modifiers record type

TYPE Modifiers_Rec_Type IS RECORD
(   arithmetic_operator           VARCHAR2(30)   := FND_API.G_MISS_CHAR
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
--,   base_qty                      NUMBER         := FND_API.G_MISS_NUM
--,   base_uom_code                 VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   comments                      VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   effective_period_uom          VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   estim_accrual_rate            NUMBER         := FND_API.G_MISS_NUM
,   generate_using_formula_id     NUMBER         := FND_API.G_MISS_NUM
--,   gl_class_id                   NUMBER         := FND_API.G_MISS_NUM
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   list_line_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_price                    NUMBER         := FND_API.G_MISS_NUM
--,   list_price_uom_code           VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   modifier_level_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
--,   new_price                     NUMBER         := FND_API.G_MISS_NUM
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
--,   rebate_subtype_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
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
,   accrual_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   pricing_group_sequence        NUMBER         := FND_API.G_MISS_NUM
,   incompatibility_grp_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_line_no                  VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   from_rltd_modifier_id         NUMBER         := FND_API.G_MISS_NUM
,   to_rltd_modifier_id           NUMBER         := FND_API.G_MISS_NUM
,   rltd_modifier_grp_no          NUMBER         := FND_API.G_MISS_NUM
,   rltd_modifier_grp_type        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_phase_id              NUMBER         := FND_API.G_MISS_NUM
,   product_precedence            NUMBER         := FND_API.G_MISS_NUM
,   expiration_period_start_date  DATE           := FND_API.G_MISS_DATE
,   number_expiration_periods     NUMBER         := FND_API.G_MISS_NUM
,   expiration_period_uom         VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   expiration_date               DATE           := FND_API.G_MISS_DATE
,   estim_gl_value                NUMBER         := FND_API.G_MISS_NUM
,   benefit_price_list_line_id    NUMBER         := FND_API.G_MISS_NUM
--,   recurring_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   benefit_limit                 NUMBER         := FND_API.G_MISS_NUM
,   charge_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   charge_subtype_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   benefit_qty                   NUMBER         := FND_API.G_MISS_NUM
,   benefit_uom_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   accrual_conversion_rate       NUMBER         := FND_API.G_MISS_NUM
,   proration_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   include_on_returns_flag       VARCHAR2(1)   := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Modifiers_Tbl_Type IS TABLE OF Modifiers_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Modifiers value record type

TYPE Modifiers_Val_Rec_Type IS RECORD
(   automatic                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   base_uom                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   generate_using_formula        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   gl_class                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   inventory_item                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line_type                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_price_uom                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   modifier_level                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   organization                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   override                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_break_type              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_by_formula              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   primary_uom                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   print_on_invoice              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   rebate_subtype                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   rebate_transaction_type       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   related_item                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   relationship_type             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   reprice                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   revision_reason               VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Modifiers_Val_Tbl_Type IS TABLE OF Modifiers_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Qualifiers record type
TYPE Qualifiers_Rec_Type IS RECORD
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
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   created_from_rule_id          NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   excluder_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   qualifier_attribute           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_attr_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attr_value_to       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_context             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_datatype            VARCHAR2(10)   := FND_API.G_MISS_CHAR
--,   qualifier_date_format         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_grouping_no         NUMBER         := FND_API.G_MISS_NUM
,   qualifier_id                  NUMBER         := FND_API.G_MISS_NUM
--,   qualifier_number_format       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_precedence          NUMBER         := FND_API.G_MISS_NUM
,   qualifier_rule_id             NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Qualifiers_Tbl_Type IS TABLE OF Qualifiers_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Qualifiers value record type


TYPE Qualifiers_Val_Rec_Type IS RECORD
(   created_from_rule             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_rule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Qualifiers_Val_Tbl_Type IS TABLE OF Qualifiers_Val_Rec_Type
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
,   product_attribute_datatype    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_datatype    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   MODIFIERS_index               NUMBER         := FND_API.G_MISS_NUM
);

TYPE Pricing_Attr_Tbl_Type IS TABLE OF Pricing_Attr_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Pricing_Attr value record type

TYPE Pricing_Attr_Val_Rec_Type IS RECORD
(   accumulate                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   excluder                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pricing_attribute             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   product_uom                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Pricing_Attr_Val_Tbl_Type IS TABLE OF Pricing_Attr_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_MODIFIER_LIST_REC      Modifier_List_Rec_Type;
G_MISS_MODIFIER_LIST_VAL_REC  Modifier_List_Val_Rec_Type;
G_MISS_MODIFIER_LIST_TBL      Modifier_List_Tbl_Type;
G_MISS_MODIFIER_LIST_VAL_TBL  Modifier_List_Val_Tbl_Type;
G_MISS_MODIFIERS_REC          Modifiers_Rec_Type;
G_MISS_MODIFIERS_VAL_REC      Modifiers_Val_Rec_Type;
G_MISS_MODIFIERS_TBL          Modifiers_Tbl_Type;
G_MISS_MODIFIERS_VAL_TBL      Modifiers_Val_Tbl_Type;
G_MISS_QUALIFIERS_REC         QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
G_MISS_QUALIFIERS_VAL_REC     QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;
G_MISS_QUALIFIERS_TBL         QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
G_MISS_QUALIFIERS_VAL_TBL     QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
G_MISS_PRICING_ATTR_REC       Pricing_Attr_Rec_Type;
G_MISS_PRICING_ATTR_VAL_REC   Pricing_Attr_Val_Rec_Type;
G_MISS_PRICING_ATTR_TBL       Pricing_Attr_Tbl_Type;
G_MISS_PRICING_ATTR_VAL_TBL   Pricing_Attr_Val_Tbl_Type;
*/

--  Start of Comments
--  API name    Process_Modifiers
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

PROCEDURE Process_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
								QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_MODIFIERS_PUB.Modifier_List_Rec_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIER_LIST_val_rec         IN  QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIER_LIST_VAL_REC
,   p_MODIFIERS_tbl                 IN  QP_MODIFIERS_PUB.Modifiers_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIERS_TBL
,   p_MODIFIERS_val_tbl             IN  QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIERS_VAL_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Modifiers
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

PROCEDURE Lock_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_MODIFIERS_PUB.Modifier_List_Rec_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIER_LIST_val_rec         IN  QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIER_LIST_VAL_REC
,   p_MODIFIERS_tbl                 IN  QP_MODIFIERS_PUB.Modifiers_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIERS_TBL
,   p_MODIFIERS_val_tbl             IN  QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_MODIFIERS_VAL_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_MODIFIERS_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Modifiers
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

PROCEDURE Get_Modifiers
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
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type
);

END QP_Modifiers_GRP;

 

/
