--------------------------------------------------------
--  DDL for Package QP_QP_FORM_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_MODIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXFMLLS.pls 120.2 2006/02/22 21:48:23 prarasto noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_list_header_id                IN NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_arithmetic_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_gl_class_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_list_price_uom_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_new_price                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_trxn_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_relationship_type_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_substitution_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_context          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_gl_class                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_list_price_uom                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_group_sequence        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_incompatibility_grp_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_start_date  OUT NOCOPY /* file.sql.39 change */ DATE
,   x_number_expiration_periods     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_uom         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_gl_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_price_list_line_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_recurring_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_limit                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_conversion_rate       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_proration_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_to_rltd_modifier_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_no          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_net_amount_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accum_attribute               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_continuous_price_break_flag       OUT NOCOPY VARCHAR2  --Continuous Price Breaks
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
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
,   x_arithmetic_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_gl_class_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_list_price_uom_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_new_price                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_trxn_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_relationship_type_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_substitution_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_context          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_gl_class                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_list_price_uom                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_group_sequence        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_incompatibility_grp_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_start_date  OUT NOCOPY /* file.sql.39 change */ DATE
,   x_number_expiration_periods     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_uom         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_gl_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_price_list_line_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_recurring_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_limit                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_conversion_rate       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_proration_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_to_rltd_modifier_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_no          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_net_amount_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accum_attribute               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_continuous_price_break_flag       OUT NOCOPY VARCHAR2  --Continuous Price Breaks
 );

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
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
,   p_list_line_id                  IN  NUMBER
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
,   p_arithmetic_operator           IN  VARCHAR2
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
,   p_automatic_flag                IN  VARCHAR2
--,   p_base_qty                      IN  NUMBER
,   p_pricing_phase_id              IN  NUMBER
--,   p_base_uom_code                 IN  VARCHAR2
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_effective_period_uom          IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_estim_accrual_rate            IN  NUMBER
,   p_generate_using_formula_id     IN  NUMBER
--,   p_gl_class_id                   IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_list_line_type_code           IN  VARCHAR2
,   p_list_price                    IN  NUMBER
--,   p_list_price_uom_code           IN  VARCHAR2
,   p_modifier_level_code           IN  VARCHAR2
--,   p_new_price                     IN  NUMBER
,   p_number_effective_periods      IN  NUMBER
,   p_operand                       IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_override_flag                 IN  VARCHAR2
,   p_percent_price                 IN  NUMBER
,   p_price_break_type_code         IN  VARCHAR2
,   p_price_by_formula_id           IN  NUMBER
,   p_primary_uom_flag              IN  VARCHAR2
,   p_print_on_invoice_flag         IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
--,   p_rebate_subtype_code           IN  VARCHAR2
,   p_rebate_trxn_type_code         IN  VARCHAR2
,   p_related_item_id               IN  NUMBER
,   p_relationship_type_id          IN  NUMBER
,   p_reprice_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_substitution_attribute        IN  VARCHAR2
,   p_substitution_context          IN  VARCHAR2
,   p_substitution_value            IN  VARCHAR2
,   p_accrual_flag                  IN  VARCHAR2
,   p_pricing_group_sequence        IN  NUMBER
,   p_incompatibility_grp_code      IN  VARCHAR2
,   p_list_line_no                  IN  VARCHAR2
,   p_product_precedence            IN  NUMBER
,   p_expiration_period_start_date  IN  DATE
,   p_number_expiration_periods     IN  NUMBER
,   p_expiration_period_uom         IN  VARCHAR2
,   p_expiration_date               IN  DATE
,   p_estim_gl_value                IN  NUMBER
,   p_benefit_price_list_line_id    IN  NUMBER
--,   p_recurring_flag                IN  VARCHAR2
,   p_benefit_limit                 IN  NUMBER
,   p_charge_type_code              IN  VARCHAR2
,   p_charge_subtype_code           IN  VARCHAR2
,   p_benefit_qty                   IN  NUMBER
,   p_benefit_uom_code              IN  VARCHAR2
,   p_accrual_conversion_rate       IN  NUMBER
,   p_proration_type_code           IN  VARCHAR2
,   p_include_on_returns_flag       IN  VARCHAR2
,   p_from_rltd_modifier_id         IN  NUMBER
,   p_to_rltd_modifier_id           IN  NUMBER
,   p_rltd_modifier_grp_no          IN  NUMBER
,   p_rltd_modifier_grp_type        IN  VARCHAR2
,   p_net_amount_flag               IN  VARCHAR2
,   p_accum_attribute               IN  VARCHAR2
,   p_continuous_price_break_flag   IN  VARCHAR2  --Continuous Price Breaks
);




-- added by svdeshmu for delayed request on feb 24 ,00

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                IN  NUMBER
);



-- End of additions by svdeshmu for delayed request

-- Following procedure is added for the ER 2423045

Procedure Dup_record
(  p_old_list_line_id                     IN NUMBER,
   p_new_list_line_id                     IN NUMBER,
   p_list_header_id			  IN NUMBER,
   p_list_line_type_code		  IN VARCHAR2,
   x_msg_count                            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data                             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_return_status                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END QP_QP_Form_Modifiers;

 

/
