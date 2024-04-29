--------------------------------------------------------
--  DDL for Package OE_OE_FORM_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_HEADER_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXFHADS.pls 120.0 2005/06/01 01:20:00 appldev noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_line_id			    IN  NUMBER
,   x_price_adjustment_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_header_id                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_discount_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_discount_line_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_line_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id 			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id	  			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_mechanism_type_code  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_updated_flag				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_update_allowed			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_applied_flag				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_change_reason_code 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_change_reason_text		      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modified_from			      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modified_to				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_operand					 OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_arithmetic_operator		 OUT NOCOPY /* file.sql.39 change */	varchar2
,   x_adjusted_amount			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_rebate_transaction_type_code  OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_rebate_transaction_reference  OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_rebate_payment_system_code    OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_redeemed_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_redeemed_flag                 OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_invoiced_flag                 OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_estimated_flag                OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_credit_or_charge_flag         OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_ac_context                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute1                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute2                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute3                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute4                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute5                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute6                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute7                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute8                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute9                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute10                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute11                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute12                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute13                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute14                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute15                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--uom begin
,   x_operand_per_pqty                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_adjusted_amount_per_pqty         OUT NOCOPY /* file.sql.39 change */ NUMBER
--uom end
);

--  Procedure   :   Change_Attributes
--

PROCEDURE Change_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_adjustment_id           IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value1                   IN  VARCHAR2
,   p_attr_value2                   IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,   p_context                       IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_ac_context                    IN  VARCHAR2
,   p_ac_attribute1                 IN  VARCHAR2
,   p_ac_attribute2                 IN  VARCHAR2
,   p_ac_attribute3                 IN  VARCHAR2
,   p_ac_attribute4                 IN  VARCHAR2
,   p_ac_attribute5                 IN  VARCHAR2
,   p_ac_attribute6                 IN  VARCHAR2
,   p_ac_attribute7                 IN  VARCHAR2
,   p_ac_attribute8                 IN  VARCHAR2
,   p_ac_attribute9                 IN  VARCHAR2
,   p_ac_attribute10                IN  VARCHAR2
,   p_ac_attribute11                IN  VARCHAR2
,   p_ac_attribute12                IN  VARCHAR2
,   p_ac_attribute13                IN  VARCHAR2
,   p_ac_attribute14                IN  VARCHAR2
,   p_ac_attribute15                IN  VARCHAR2
,   x_price_adjustment_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_header_id                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_discount_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_discount_line_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_line_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_context                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute1                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute2                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute3                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute4                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute5                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute6                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute7                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute8                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute9                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute10                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute11                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute12                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute13                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute14                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ac_attribute15                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_enforce_fixed_price	      IN  VARCHAR2

-- New code added
,   x_list_header_id 			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id	  			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_mechanism_type_code  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_updated_flag				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_update_allowed			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_applied_flag				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_change_reason_code 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_change_reason_text		      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modified_from			      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modified_to				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_operand					 OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_arithmetic_operator		 OUT NOCOPY /* file.sql.39 change */	varchar2
,   x_adjusted_amount			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */  DATE
,   x_rebate_transaction_type_code  OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_rebate_transaction_reference  OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_rebate_payment_system_code    OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_redeemed_date                 OUT NOCOPY /* file.sql.39 change */  DATE
,   x_redeemed_flag                 OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_invoiced_flag                 OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_estimated_flag                OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_credit_or_charge_flag         OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */  varchar2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */  varchar2
--uom begin
,       x_operand_per_pqty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,       x_adjusted_amount_per_pqty              OUT NOCOPY /* file.sql.39 change */ NUMBER
--uom end
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_adjustment_id           IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   p_ok_flag			    		 IN VARCHAR2
,   x_program_id				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_application_id		 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_update_date		 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_request_id				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_lock_control				 OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_adjustment_id           IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Delayed_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id			    IN  NUMBER
);


--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_adjustment_id    IN  NUMBER
,   p_lock_control           IN  NUMBER
);

END OE_OE_Form_Header_Adj;

 

/
