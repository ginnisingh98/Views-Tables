--------------------------------------------------------
--  DDL for Package OZF_CLAIM_LINES_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_LINES_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftclhs.pls 115.4 2004/01/13 09:44:38 upoluri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_CLAIM_LINES_HIST_PKG
-- Purpose
--
-- History
--
--    MCHANG      23-OCT-2001      Remove security_group_id.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_claim_line_history_id    IN OUT NOCOPY NUMBER,
          px_object_version_number    IN OUT NOCOPY NUMBER,
          p_last_update_date          DATE,
          p_last_updated_by           NUMBER,
          p_creation_date             DATE,
          p_created_by                NUMBER,
          p_last_update_login         NUMBER,
          p_request_id                NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date       DATE,
          p_program_id                NUMBER,
          p_created_from              VARCHAR2,
          p_claim_history_id          NUMBER,
          p_claim_id                  NUMBER,
          p_claim_line_id             NUMBER,
          p_line_number               NUMBER,
          p_split_from_claim_line_id  NUMBER,
          p_amount                    NUMBER,
          p_acctd_amount              NUMBER,
          p_currency_code             VARCHAR2,
          p_exchange_rate_type        VARCHAR2,
          p_exchange_rate_date        DATE,
          p_exchange_rate             NUMBER,
          p_set_of_books_id           NUMBER,
          p_valid_flag                VARCHAR2,
          p_source_object_id          NUMBER,
          p_source_object_class       VARCHAR2,
          p_source_object_type_id     NUMBER,
	  p_source_object_line_id     NUMBER,
          p_plan_id                   NUMBER,
          p_offer_id                  NUMBER,
          p_payment_method            VARCHAR2,
          p_payment_reference_id      NUMBER,
          p_payment_reference_number  VARCHAR2,
          p_payment_reference_date    DATE,
          p_voucher_id                NUMBER,
          p_voucher_number            VARCHAR2,
          p_payment_status            VARCHAR2,
          p_approved_flag             VARCHAR2,
          p_approved_date             DATE,
          p_approved_by               NUMBER,
          p_settled_date              DATE,
          p_settled_by                NUMBER,
          p_performance_complete_flag VARCHAR2,
          p_performance_attached_flag VARCHAR2,
          p_attribute_category        VARCHAR2,
          p_attribute1                VARCHAR2,
          p_attribute2                VARCHAR2,
          p_attribute3                VARCHAR2,
          p_attribute4                VARCHAR2,
          p_attribute5                VARCHAR2,
          p_attribute6                VARCHAR2,
          p_attribute7                VARCHAR2,
          p_attribute8                VARCHAR2,
          p_attribute9                VARCHAR2,
          p_attribute10               VARCHAR2,
          p_attribute11               VARCHAR2,
          p_attribute12               VARCHAR2,
          p_attribute13               VARCHAR2,
          p_attribute14               VARCHAR2,
          p_attribute15               VARCHAR2,
          px_org_id                   IN OUT NOCOPY NUMBER,
          p_utilization_id            NUMBER,
          p_claim_currency_amount     NUMBER,
          p_item_id                   NUMBER,
          p_item_description          VARCHAR2,
          p_quantity                  NUMBER,
          p_quantity_uom              VARCHAR2,
          p_rate                      NUMBER,
          p_activity_type             VARCHAR2,
          p_activity_id               NUMBER,
          p_earnings_associated_flag  VARCHAR2,
          p_comments                  VARCHAR2,
          p_related_cust_account_id   NUMBER,
          p_relationship_type         VARCHAR2,
          p_tax_code                  VARCHAR2,
          p_select_cust_children_flag VARCHAR2,
          p_buy_group_cust_account_id NUMBER,
          p_credit_to                 VARCHAR2,
          p_sale_date                 DATE,
          p_item_type                 VARCHAR2,
          p_tax_amount                NUMBER,
          p_claim_curr_tax_amount     NUMBER,
          p_activity_line_id          NUMBER,
          p_offer_type                VARCHAR2,
          p_prorate_earnings_flag     VARCHAR2,
          p_earnings_end_date         DATE
);


PROCEDURE Update_Row(
          p_claim_line_history_id      NUMBER,
          p_object_version_number      NUMBER,
          p_last_update_date           DATE,
          p_last_updated_by            NUMBER,
          p_last_update_login          NUMBER,
          p_request_id                 NUMBER,
          p_program_application_id     NUMBER,
          p_program_update_date        DATE,
          p_program_id                 NUMBER,
          p_created_from               VARCHAR2,
          p_claim_history_id           NUMBER,
          p_claim_id                   NUMBER,
          p_claim_line_id              NUMBER,
          p_line_number                NUMBER,
          p_split_from_claim_line_id   NUMBER,
          p_amount                     NUMBER,
          p_acctd_amount               NUMBER,
          p_currency_code              VARCHAR2,
          p_exchange_rate_type         VARCHAR2,
          p_exchange_rate_date         DATE,
          p_exchange_rate              NUMBER,
          p_set_of_books_id            NUMBER,
          p_valid_flag                 VARCHAR2,
          p_source_object_id           NUMBER,
          p_source_object_class        VARCHAR2,
          p_source_object_type_id      NUMBER,
	  p_source_object_line_id      NUMBER,
          p_plan_id                    NUMBER,
          p_offer_id                   NUMBER,
          p_payment_method             VARCHAR2,
          p_payment_reference_id       NUMBER,
          p_payment_reference_number   VARCHAR2,
          p_payment_reference_date     DATE,
          p_voucher_id                 NUMBER,
          p_voucher_number             VARCHAR2,
          p_payment_status             VARCHAR2,
          p_approved_flag              VARCHAR2,
          p_approved_date              DATE,
          p_approved_by                NUMBER,
          p_settled_date               DATE,
          p_settled_by                 NUMBER,
          p_performance_complete_flag  VARCHAR2,
          p_performance_attached_flag  VARCHAR2,
          p_attribute_category         VARCHAR2,
          p_attribute1                 VARCHAR2,
          p_attribute2                 VARCHAR2,
          p_attribute3                 VARCHAR2,
          p_attribute4                 VARCHAR2,
          p_attribute5                 VARCHAR2,
          p_attribute6                 VARCHAR2,
          p_attribute7                 VARCHAR2,
          p_attribute8                 VARCHAR2,
          p_attribute9                 VARCHAR2,
          p_attribute10                VARCHAR2,
          p_attribute11                VARCHAR2,
          p_attribute12                VARCHAR2,
          p_attribute13                VARCHAR2,
          p_attribute14                VARCHAR2,
          p_attribute15                VARCHAR2,
          p_org_id                     NUMBER,
          p_utilization_id             NUMBER,
          p_claim_currency_amount      NUMBER,
          p_item_id                    NUMBER,
          p_item_description           VARCHAR2,
          p_quantity                   NUMBER,
          p_quantity_uom               VARCHAR2,
          p_rate                       NUMBER,
          p_activity_type              VARCHAR2,
          p_activity_id                NUMBER,
          p_earnings_associated_flag   VARCHAR2,
          p_comments                   VARCHAR2,
          p_related_cust_account_id    NUMBER,
          p_relationship_type          VARCHAR2,
          p_tax_code                   VARCHAR2,
          p_select_cust_children_flag  VARCHAR2,
          p_buy_group_cust_account_id  NUMBER,
          p_credit_to                  VARCHAR2,
          p_sale_date                 DATE,
          p_item_type                 VARCHAR2,
          p_tax_amount                NUMBER,
          p_claim_curr_tax_amount     NUMBER,
          p_activity_line_id          NUMBER,
          p_offer_type                VARCHAR2,
          p_prorate_earnings_flag     VARCHAR2,
          p_earnings_end_date         DATE
);


PROCEDURE Delete_Row(
    p_claim_line_history_id  NUMBER
);


PROCEDURE Lock_Row(
          p_claim_line_history_id       NUMBER,
          p_object_version_number       NUMBER,
          p_last_update_date            DATE,
          p_last_updated_by             NUMBER,
          p_creation_date               DATE,
          p_created_by                  NUMBER,
          p_last_update_login           NUMBER,
          p_request_id                  NUMBER,
          p_program_application_id      NUMBER,
          p_program_update_date         DATE,
          p_program_id                  NUMBER,
          p_created_from                VARCHAR2,
          p_claim_history_id            NUMBER,
          p_claim_id                    NUMBER,
          p_claim_line_id               NUMBER,
          p_line_number                 NUMBER,
          p_split_from_claim_line_id    NUMBER,
          p_amount                      NUMBER,
          p_acctd_amount                NUMBER,
          p_currency_code               VARCHAR2,
          p_exchange_rate_type          VARCHAR2,
          p_exchange_rate_date          DATE,
          p_exchange_rate               NUMBER,
          p_set_of_books_id             NUMBER,
          p_valid_flag                  VARCHAR2,
          p_source_object_id            NUMBER,
          p_source_object_class         VARCHAR2,
          p_source_object_type_id       NUMBER,
	  p_source_object_line_id       NUMBER,
          p_plan_id                     NUMBER,
          p_offer_id                    NUMBER,
          p_payment_method              VARCHAR2,
          p_payment_reference_id        NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date      DATE,
          p_voucher_id                  NUMBER,
          p_voucher_number              VARCHAR2,
          p_payment_status              VARCHAR2,
          p_approved_flag               VARCHAR2,
          p_approved_date               DATE,
          p_approved_by                 NUMBER,
          p_settled_date                DATE,
          p_settled_by                  NUMBER,
          p_performance_complete_flag   VARCHAR2,
          p_performance_attached_flag   VARCHAR2,
          p_attribute_category          VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_org_id                      NUMBER,
          p_utilization_id              NUMBER,
          p_claim_currency_amount       NUMBER,
          p_item_id                     NUMBER,
          p_item_description            VARCHAR2,
          p_quantity                    NUMBER,
          p_quantity_uom                VARCHAR2,
          p_rate                        NUMBER,
          p_activity_type               VARCHAR2,
          p_activity_id                 NUMBER,
          p_earnings_associated_flag    VARCHAR2,
          p_comments                    VARCHAR2,
          p_related_cust_account_id     NUMBER,
          p_relationship_type           VARCHAR2,
          p_tax_code                    VARCHAR2,
          p_select_cust_children_flag   VARCHAR2,
          p_buy_group_cust_account_id   NUMBER,
          p_credit_to                   VARCHAR2,
          p_sale_date                 DATE,
          p_item_type                 VARCHAR2,
          p_tax_amount                NUMBER,
          p_claim_curr_tax_amount     NUMBER,
          p_activity_line_id          NUMBER,
          p_offer_type                VARCHAR2,
          p_prorate_earnings_flag     VARCHAR2,
          p_earnings_end_date         DATE
);

END OZF_CLAIM_LINES_HIST_PKG;

 

/