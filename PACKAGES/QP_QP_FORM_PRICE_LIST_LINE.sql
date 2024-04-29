--------------------------------------------------------
--  DDL for Package QP_QP_FORM_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_PRICE_LIST_LINE" AUTHID CURRENT_USER AS
/* $Header: QPXFPLLS.pls 120.2 2006/02/22 06:20:48 prarasto noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN NUMBER
,   x_accrual_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accrual_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_group_no        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_accrual_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_from_rltd_modifier_id         IN  NUMBER := NULL
,   x_recurring_value               OUT NOCOPY /* file.sql.39 change */ NUMBER -- block pricing
,   x_customer_item_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_break_uom_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS
,   x_break_uom_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_continuous_price_break_flag       OUT NOCOPY                          VARCHAR2 --Continuous Price Breaks
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
,   x_accrual_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accrual_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_group_no        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_accrual_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_recurring_value               OUT NOCOPY /* file.sql.39 change */ NUMBER -- block pricing
,   x_customer_item_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_break_uom_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS
,   x_break_uom_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_continuous_price_break_flag       OUT NOCOPY                          VARCHAR2 --Continuous Price Breaks
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
,   x_program_application_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_update_date           OUT NOCOPY /* file.sql.39 change */ DATE
,   x_request_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
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
,   p_accrual_qty                   IN  NUMBER
,   p_accrual_uom_code              IN  VARCHAR2
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
,   p_base_qty                      IN  NUMBER
,   p_base_uom_code                 IN  VARCHAR2
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_effective_period_uom          IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_estim_accrual_rate            IN  NUMBER
,   p_generate_using_formula_id     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_list_line_type_code           IN  VARCHAR2
,   p_list_price                    IN  NUMBER
,   p_product_precedence            IN  NUMBER
,   p_modifier_level_code           IN  VARCHAR2
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
,   p_recurring_value               IN  NUMBER -- block pricing
,   p_customer_item_id              IN  NUMBER
,   p_break_uom_code                IN VARCHAR2 -- OKS proration
,   p_break_uom_context             IN VARCHAR2 -- OKS
,   p_break_uom_attribute           IN VARCHAR2 -- OKS proration
,   p_continuous_price_break_flag   IN VARCHAR2 --Continuous Price Breaks
);

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
);

Procedure Delete_All_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END QP_QP_Form_Price_List_Line;

 

/
