--------------------------------------------------------
--  DDL for Package OE_PRICING_CONT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICING_CONT_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPPRCS.pls 120.3 2006/02/22 10:35:10 shulin noship $ */


--  Contract record type

TYPE Contract_Rec_Type IS RECORD
(   agreement_id                  NUMBER         := FND_API.G_MISS_NUM
,   attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   discount_id                   NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   price_list_id                 NUMBER         := FND_API.G_MISS_NUM
,   pricing_contract_id           NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Contract_Tbl_Type IS TABLE OF Contract_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Contract value record type

TYPE Contract_Val_Rec_Type IS RECORD
(   agreement                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Contract_Val_Tbl_Type IS TABLE OF Contract_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Agreement record type

TYPE Agreement_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER         := FND_API.G_MISS_NUM
,   agreement_contact_id          NUMBER         := FND_API.G_MISS_NUM
,   agreement_id                  NUMBER         := FND_API.G_MISS_NUM
,   agreement_num                 VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   agreement_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   comments                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   sold_to_org_id                   NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   freight_terms_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   invoice_contact_id            NUMBER         := FND_API.G_MISS_NUM
,   invoice_to_org_id        	    NUMBER         := FND_API.G_MISS_NUM
,   invoicing_rule_id             NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
-- Bug 1815153
,   name                          VARCHAR2(240)   := FND_API.G_MISS_CHAR
,   override_arule_flag           VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   override_irule_flag           VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   price_list_id                 NUMBER         := FND_API.G_MISS_NUM
,   pricing_contract_id		  NUMBER	 := FND_API.G_MISS_NUM
,   purchase_order_num            VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   revision                      VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   revision_date                 DATE           := FND_API.G_MISS_DATE
,   revision_reason_code          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   salesrep_id                   NUMBER         := FND_API.G_MISS_NUM
,   ship_method_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   signature_date                DATE           := FND_API.G_MISS_DATE
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   term_id                       NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   tp_attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute10                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute11                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute12                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute13                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute14                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute15                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   tp_attribute_category             VARCHAR2(30)  := FND_API.G_MISS_CHAR
,   agreement_source_code             VARCHAR2(30)  := FND_API.G_MISS_CHAR
                                              --added by rchellam for OKC
,   orig_system_agr_id                NUMBER        := FND_API.G_MISS_NUM
                                              --added by rchellam for OKC
,   invoice_to_customer_id            NUMBER        := FND_API.G_MISS_NUM
                                                 -- Added for bug#4029589
);

TYPE Agreement_Tbl_Type IS TABLE OF Agreement_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Agreement value record type

TYPE Agreement_Val_Rec_Type IS RECORD
(   accounting_rule               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   agreement_contact             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   agreement                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   agreement_type                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   customer                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   freight_terms                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   invoice_contact               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   invoice_to_site_use           VARCHAR2(240)  := FND_API.G_MISS_CHAR
/* ,   invoice_to_org           	    VARCHAR2(240)  := FND_API.G_MISS_CHAR */
,   invoicing_rule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   override_arule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   override_irule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   revision_reason               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   salesrep                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   ship_method                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   term                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   agreement_source              VARCHAR2(240)  := FND_API.G_MISS_CHAR --added by rchellam for OKC
);

TYPE Agreement_Val_Tbl_Type IS TABLE OF Agreement_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Discount_Header record type

TYPE Discount_Header_Rec_Type IS RECORD
(   amount                        NUMBER         := FND_API.G_MISS_NUM
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   automatic_discount_flag       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   description                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount_id                   NUMBER         := FND_API.G_MISS_NUM
,   discount_lines_flag           VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   discount_type_code            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   gsa_indicator                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   manual_discount_flag          VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   name                          VARCHAR2(240)   := FND_API.G_MISS_CHAR
,   override_allowed_flag         VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   percent                       NUMBER         := FND_API.G_MISS_NUM
,   price_list_id                 NUMBER         := FND_API.G_MISS_NUM
,   pricing_contract_id         NUMBER   := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   prorate_flag                  VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Discount_Header_Tbl_Type IS TABLE OF Discount_Header_Rec_Type
    INDEX BY BINARY_INTEGER;

    --  Discount_Header value record type

    TYPE Discount_Header_Val_Rec_Type IS RECORD
    (   automatic_discount            VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   discount                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   discount_lines                VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   discount_type                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   manual_discount               VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   override_allowed              VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   price_list                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   prorate                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
    );

    TYPE Discount_Header_Val_Tbl_Type IS TABLE OF Discount_Header_Val_Rec_Type
	   INDEX BY BINARY_INTEGER;


--  Discount_Cust record type

TYPE Discount_Cust_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   customer_class_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
/* ,   customer_id                   NUMBER         := FND_API.G_MISS_NUM  */
,   sold_to_org_id                   NUMBER         := FND_API.G_MISS_NUM
,   discount_customer_id          NUMBER         := FND_API.G_MISS_NUM
,   discount_id                   NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
/*,   site_use_id                   NUMBER         := FND_API.G_MISS_NUM  */
,   site_org_id                   NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Discount_Cust_Tbl_Type IS TABLE OF Discount_Cust_Rec_Type
    INDEX BY BINARY_INTEGER;

    --  Discount_Cust value record type

    TYPE Discount_Cust_Val_Rec_Type IS RECORD
    (   customer_class                VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   customer                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   discount_customer             VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   discount                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
    ,   site_use                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
    );

    TYPE Discount_Cust_Val_Tbl_Type IS TABLE OF Discount_Cust_Val_Rec_Type
	   INDEX BY BINARY_INTEGER;

--  Discount_Line record type

TYPE Discount_Line_Rec_Type IS RECORD
(   amount                        NUMBER         := FND_API.G_MISS_NUM
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   customer_item_id              NUMBER         := FND_API.G_MISS_NUM
,   discount_id                   NUMBER         := FND_API.G_MISS_NUM
,   discount_line_id              NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   entity_id                     NUMBER         := FND_API.G_MISS_NUM
,   entity_value                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   percent                       NUMBER         := FND_API.G_MISS_NUM
,   price                         NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Discount_Line_Tbl_Type IS TABLE OF Discount_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Discount_Line value record type

TYPE Discount_Line_Val_Rec_Type IS RECORD
(   customer_item                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   discount_line                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   entity                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Discount_Line_Val_Tbl_Type IS TABLE OF Discount_Line_Val_Rec_Type
   INDEX BY BINARY_INTEGER;

--  Price_Break record type

TYPE Price_Break_Rec_Type IS RECORD
(   amount                        NUMBER         := FND_API.G_MISS_NUM
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   discount_line_id              NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   method_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   percent                       NUMBER         := FND_API.G_MISS_NUM
,   price                         NUMBER         := FND_API.G_MISS_NUM
,   price_break_high              NUMBER         := FND_API.G_MISS_NUM
,   price_break_low               NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   unit_code                     VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Discount_Line_index           NUMBER         := FND_API.G_MISS_NUM
);

TYPE Price_Break_Tbl_Type IS TABLE OF Price_Break_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Price_Break value record type

TYPE Price_Break_Val_Rec_Type IS RECORD
(   discount_line                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   method_type                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   unit                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Price_Break_Val_Tbl_Type IS TABLE OF Price_Break_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_AGREEMENT_REC          Agreement_Rec_Type;
G_MISS_AGREEMENT_VAL_REC      Agreement_Val_Rec_Type;
G_MISS_AGREEMENT_TBL          Agreement_Tbl_Type;
G_MISS_AGREEMENT_VAL_TBL      Agreement_Val_Tbl_Type;
G_MISS_PRICE_LIST_REC         QP_Price_List_PUB.Price_List_Rec_Type;
G_MISS_PRICE_LIST_VAL_REC     QP_Price_List_PUB.Price_List_Val_Rec_Type;
G_MISS_PRICE_LIST_TBL         QP_Price_List_PUB.Price_List_Tbl_Type;
G_MISS_PRICE_LIST_VAL_TBL     QP_Price_List_PUB.Price_List_Val_Tbl_Type;
G_MISS_PRICE_LIST_LINE_REC    QP_Price_List_PUB.Price_List_Line_Rec_Type;
G_MISS_PRICE_LIST_LINE_VAL_REC   QP_Price_List_PUB.Price_List_Line_Val_Rec_Type;
G_MISS_PRICE_LIST_LINE_TBL       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
G_MISS_PRICE_LIST_LINE_VAL_TBL   QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type;
G_MISS_QUALIFIERS_REC         QP_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
G_MISS_QUALIFIERS_VAL_REC     QP_Qualifier_Rules_Pub.Qualifiers_Val_Rec_Type;
G_MISS_QUALIFIERS_TBL         QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
G_MISS_QUALIFIERS_VAL_TBL     QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
G_MISS_PRICING_ATTR_REC       QP_Price_List_PUB.Pricing_Attr_Rec_Type;
G_MISS_PRICING_ATTR_VAL_REC   QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type;
G_MISS_PRICING_ATTR_TBL       QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
G_MISS_PRICING_ATTR_VAL_TBL   QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type;


G_MISS_CONTRACT_REC           Contract_Rec_Type;
G_MISS_CONTRACT_VAL_REC       Contract_Val_Rec_Type;
G_MISS_CONTRACT_TBL           Contract_Tbl_Type;
G_MISS_CONTRACT_VAL_TBL       Contract_Val_Tbl_Type;

G_MISS_DISCOUNT_HEADER_REC    Discount_Header_Rec_Type;
G_MISS_DISCOUNT_HEADER_VAL_REC Discount_Header_Val_Rec_Type;
G_MISS_DISCOUNT_HEADER_TBL    Discount_Header_Tbl_Type;
G_MISS_DISCOUNT_HEADER_VAL_TBL Discount_Header_Val_Tbl_Type;
G_MISS_DISCOUNT_CUST_REC      Discount_Cust_Rec_Type;
G_MISS_DISCOUNT_CUST_VAL_REC  Discount_Cust_Val_Rec_Type;
G_MISS_DISCOUNT_CUST_TBL      Discount_Cust_Tbl_Type;
G_MISS_DISCOUNT_CUST_VAL_TBL  Discount_Cust_Val_Tbl_Type;
G_MISS_DISCOUNT_LINE_REC      Discount_Line_Rec_Type;
G_MISS_DISCOUNT_LINE_VAL_REC  Discount_Line_Val_Rec_Type;
G_MISS_DISCOUNT_LINE_TBL      Discount_Line_Tbl_Type;
G_MISS_DISCOUNT_LINE_VAL_TBL  Discount_Line_Val_Tbl_Type;

G_MISS_PRICE_BREAK_REC        Price_Break_Rec_Type;
G_MISS_PRICE_BREAK_VAL_REC    Price_Break_Val_Rec_Type;
G_MISS_PRICE_BREAK_TBL        Price_Break_Tbl_Type;
G_MISS_PRICE_BREAK_VAL_TBL    Price_Break_Val_Tbl_Type;


--  Start of Comments
--  API name    Process_Agreement
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

PROCEDURE Process_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  Agreement_Rec_Type :=
                                        G_MISS_AGREEMENT_REC
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type :=
                                        G_MISS_AGREEMENT_VAL_REC
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
								G_MISS_PRICING_ATTR_TBL
,   p_Pricing_Attr_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
          						G_MISS_PRICING_ATTR_VAL_TBL
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   p_check_duplicate_lines         IN  VARCHAR2 DEFAULT NULL  --5018856, 5024801, 5024919
);

--  Start of Comments
--  API name    Lock_Agreement
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

PROCEDURE Lock_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  Agreement_Rec_Type :=
                                        G_MISS_AGREEMENT_REC
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type :=
                                        G_MISS_AGREEMENT_VAL_REC
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
								G_MISS_PRICING_ATTR_TBL
,   p_Pricing_Attr_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
     							G_MISS_PRICING_ATTR_VAL_TBL
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Agreement
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

PROCEDURE Get_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id           		 IN  NUMBER := FND_API.G_MISS_NUM
/*,   p_agreement	                IN  VARCHAR2 := FND_API.G_MISS_CHAR
,     p_revision                    IN  VARCHAR2 := FND_API.G_MISS_CHAR */
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

END OE_Pricing_Cont_PUB;

 

/
