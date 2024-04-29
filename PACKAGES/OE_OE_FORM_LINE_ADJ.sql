--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LINE_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXFLADS.pls 120.0 2005/06/01 01:13:25 appldev noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   p_line_id			           IN  NUMBER
, x_price_adjustment_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_discount_id OUT NOCOPY NUMBER

, x_discount_line_id OUT NOCOPY NUMBER

, x_automatic_flag OUT NOCOPY VARCHAR2

, x_percent OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_discount OUT NOCOPY VARCHAR2

, x_list_header_id OUT NOCOPY NUMBER

, x_list_line_id OUT NOCOPY NUMBER

, x_list_line_type_code OUT NOCOPY VARCHAR2

, x_modifier_mechanism_type_code OUT NOCOPY VARCHAR2

, x_updated_flag OUT NOCOPY VARCHAR2

, x_update_allowed OUT NOCOPY VARCHAR2

, x_applied_flag OUT NOCOPY VARCHAR2

, x_change_reason_code OUT NOCOPY VARCHAR2

, x_change_reason_text OUT NOCOPY VARCHAR2

, x_modified_from OUT NOCOPY VARCHAR2

, x_modified_to OUT NOCOPY VARCHAR2

, x_operand OUT NOCOPY NUMBER

, x_arithmetic_operator OUT NOCOPY VARCHAR2

, x_adjusted_amount OUT NOCOPY NUMBER

, x_pricing_phase_id OUT NOCOPY NUMBER

, x_list_line_no OUT NOCOPY varchar2

, x_source_system_code OUT NOCOPY varchar2

, x_benefit_qty OUT NOCOPY NUMBER

, x_benefit_uom_code OUT NOCOPY varchar2

, x_print_on_invoice_flag OUT NOCOPY varchar2

, x_expiration_date OUT NOCOPY DATE

, x_rebate_transaction_type_code OUT NOCOPY varchar2

, x_rebate_transaction_reference OUT NOCOPY varchar2

, x_rebate_payment_system_code OUT NOCOPY varchar2

, x_redeemed_date OUT NOCOPY DATE

, x_redeemed_flag OUT NOCOPY varchar2

, x_accrual_flag OUT NOCOPY varchar2

, x_invoiced_flag OUT NOCOPY varchar2

, x_estimated_flag OUT NOCOPY varchar2

, x_credit_or_charge_flag OUT NOCOPY varchar2

, x_include_on_returns_flag OUT NOCOPY varchar2

, x_charge_type_code OUT NOCOPY varchar2

, x_charge_subtype_code OUT NOCOPY varchar2

, x_ac_context OUT NOCOPY VARCHAR2

, x_ac_attribute1 OUT NOCOPY VARCHAR2

, x_ac_attribute2 OUT NOCOPY VARCHAR2

, x_ac_attribute3 OUT NOCOPY VARCHAR2

, x_ac_attribute4 OUT NOCOPY VARCHAR2

, x_ac_attribute5 OUT NOCOPY VARCHAR2

, x_ac_attribute6 OUT NOCOPY VARCHAR2

, x_ac_attribute7 OUT NOCOPY VARCHAR2

, x_ac_attribute8 OUT NOCOPY VARCHAR2

, x_ac_attribute9 OUT NOCOPY VARCHAR2

, x_ac_attribute10 OUT NOCOPY VARCHAR2

, x_ac_attribute11 OUT NOCOPY VARCHAR2

, x_ac_attribute12 OUT NOCOPY VARCHAR2

, x_ac_attribute13 OUT NOCOPY VARCHAR2

, x_ac_attribute14 OUT NOCOPY VARCHAR2

, x_ac_attribute15 OUT NOCOPY VARCHAR2

--uom begin
, x_operand_per_pqty OUT NOCOPY NUMBER

, x_adjusted_amount_per_pqty OUT NOCOPY NUMBER

--uom end
);

--  Procedure   :   Change_Attributes
--

PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

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
, x_price_adjustment_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_discount_id OUT NOCOPY NUMBER

, x_discount_line_id OUT NOCOPY NUMBER

, x_automatic_flag OUT NOCOPY VARCHAR2

, x_percent OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_ac_context OUT NOCOPY VARCHAR2

, x_ac_attribute1 OUT NOCOPY VARCHAR2

, x_ac_attribute2 OUT NOCOPY VARCHAR2

, x_ac_attribute3 OUT NOCOPY VARCHAR2

, x_ac_attribute4 OUT NOCOPY VARCHAR2

, x_ac_attribute5 OUT NOCOPY VARCHAR2

, x_ac_attribute6 OUT NOCOPY VARCHAR2

, x_ac_attribute7 OUT NOCOPY VARCHAR2

, x_ac_attribute8 OUT NOCOPY VARCHAR2

, x_ac_attribute9 OUT NOCOPY VARCHAR2

, x_ac_attribute10 OUT NOCOPY VARCHAR2

, x_ac_attribute11 OUT NOCOPY VARCHAR2

, x_ac_attribute12 OUT NOCOPY VARCHAR2

, x_ac_attribute13 OUT NOCOPY VARCHAR2

, x_ac_attribute14 OUT NOCOPY VARCHAR2

, x_ac_attribute15 OUT NOCOPY VARCHAR2

, x_discount OUT NOCOPY VARCHAR2

,   p_enforce_fixed_price	      IN  VARCHAR2

-- New code Added :: New columns
, x_list_header_id OUT NOCOPY NUMBER

, x_list_line_id OUT NOCOPY NUMBER

, x_list_line_type_code OUT NOCOPY VARCHAR2

, x_modifier_mechanism_type_code OUT NOCOPY VARCHAR2

, x_updated_flag OUT NOCOPY VARCHAR2

, x_update_allowed OUT NOCOPY VARCHAR2

, x_applied_flag OUT NOCOPY VARCHAR2

, x_change_reason_code OUT NOCOPY VARCHAR2

, x_change_reason_text OUT NOCOPY VARCHAR2

, x_modified_from OUT NOCOPY VARCHAR2

, x_modified_to OUT NOCOPY VARCHAR2

, x_operand OUT NOCOPY NUMBER

, x_arithmetic_operator OUT NOCOPY varchar2

, x_adjusted_amount OUT NOCOPY NUMBER

, x_pricing_phase_id OUT NOCOPY NUMBER

, x_list_line_no OUT NOCOPY varchar2

, x_source_system_code OUT NOCOPY varchar2

, x_benefit_qty OUT NOCOPY NUMBER

, x_benefit_uom_code OUT NOCOPY varchar2

, x_print_on_invoice_flag OUT NOCOPY varchar2

, x_expiration_date OUT NOCOPY DATE

, x_rebate_transaction_type_code OUT NOCOPY varchar2

, x_rebate_transaction_reference OUT NOCOPY varchar2

, x_rebate_payment_system_code OUT NOCOPY varchar2

, x_redeemed_date OUT NOCOPY DATE

, x_redeemed_flag OUT NOCOPY varchar2

, x_accrual_flag OUT NOCOPY varchar2

, x_invoiced_flag OUT NOCOPY varchar2

, x_estimated_flag OUT NOCOPY varchar2

, x_credit_or_charge_flag OUT NOCOPY varchar2

, x_include_on_returns_flag OUT NOCOPY varchar2

, x_charge_type_code OUT NOCOPY varchar2

, x_charge_subtype_code OUT NOCOPY varchar2

--uom begin
, x_operand_per_pqty OUT NOCOPY NUMBER

, x_adjusted_amount_per_pqty OUT NOCOPY NUMBER

--uom end
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

,   p_ok_flag			    		 IN VARCHAR2
, x_program_id OUT NOCOPY NUMBER

, x_program_application_id OUT NOCOPY NUMBER

, x_program_update_date OUT NOCOPY DATE

, x_request_id OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Delayed_Requests
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id			    IN  NUMBER
,   p_line_id			    IN  NUMBER
);


--  procedure       replace_attributes
--  this is a specialized function to replace a price_adjustment
--  with a new one. this function is exclusively for internal use only.
--  it presently only being called from OEXOELIN when modifying
--  selling_price

PROCEDURE REPLACE_ATTRIBUTES
(x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

   p_price_adjustment_id	IN  NUMBER,
   p_adjusted_amount	IN  NUMBER,
   p_adjusted_amount_per_pqty	IN  NUMBER DEFAULT NULL,
   p_arithmetic_operator	IN  VARCHAR2,
   p_operand			IN  NUMBER,
   p_operand_per_pqty			IN  NUMBER DEFAULT NULL,
   p_applied_flag		IN  VARCHAR2,
   p_updated_flag		IN  VARCHAR2,
   p_change_reason_code         In  Varchar2:=NULL,
   p_change_reason_text         In  Varchar2:=NULL
   );

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
,   p_lock_control		           IN  NUMBER
);

--Manual Begin
Procedure Insert_Row(p_line_adj_rec In Oe_Order_Pub.line_adj_rec_type
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_price_adjustment_id OUT NOCOPY NUMBER);

--Manual End


END OE_OE_Form_Line_Adj;

 

/
