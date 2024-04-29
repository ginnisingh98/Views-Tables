--------------------------------------------------------
--  DDL for Package OE_OE_FORM_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_AGREEMENT" AUTHID CURRENT_USER AS
/* $Header: OEXFAGRS.pls 120.2 2005/12/14 16:10:21 shulin noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accounting_rule_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_contact_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_num                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoice_to_org_id        	    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoicing_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_purchase_order_num            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_signature_date                OUT NOCOPY /* file.sql.39 change */ DATE
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_term_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accounting_rule               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_contact             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_site_use           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoicing_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_term                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_source_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                                     --added by rchellam for OKC
,   x_orig_system_agr_id            OUT NOCOPY /* file.sql.39 change */ NUMBER --added by rchellam for OKC
,   x_agreement_source              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_invoice_to_customer_id        OUT NOCOPY NUMBER -- Added for bug#4029589
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_accounting_rule_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_contact_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_num                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoice_to_org_id        	    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoicing_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_purchase_order_num            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_signature_date                OUT NOCOPY /* file.sql.39 change */ DATE
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_term_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accounting_rule               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_contact             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_site_use           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoicing_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_term                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_source_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                                     --added by rchellam for OKC
,   x_orig_system_agr_id            OUT NOCOPY /* file.sql.39 change */ NUMBER --added by rchellam for OKC
,   x_agreement_source              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_invoice_to_customer_id        OUT NOCOPY NUMBER -- Added for bug#4029589
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_accounting_rule_id            IN  NUMBER
,   p_agreement_contact_id          IN  NUMBER
,   p_agreement_id                  IN  NUMBER
,   p_agreement_num                 IN  VARCHAR2
,   p_agreement_type_code           IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_sold_to_org_id                   IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_freight_terms_code            IN  VARCHAR2
,   p_invoice_contact_id            IN  NUMBER
,   p_invoice_to_org_id        	 IN  NUMBER
,   p_invoicing_rule_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_name                          IN  VARCHAR2
,   p_override_arule_flag           IN  VARCHAR2
,   p_override_irule_flag           IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_purchase_order_num            IN  VARCHAR2
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_salesrep_id                   IN  NUMBER
,   p_ship_method_code              IN  VARCHAR2
,   p_signature_date                IN  DATE
,   p_start_date_active             IN  DATE
,   p_term_id                       IN  NUMBER
,   p_agreement_source_code         IN  VARCHAR2
                                     --added by rchellam for OKC
,   p_orig_system_agr_id            IN  NUMBER --added by rchellam for OKC
,   p_invoice_to_customer_id        IN  NUMBER -- Added for bug#4029589
);

END OE_OE_Form_Agreement;

 

/
