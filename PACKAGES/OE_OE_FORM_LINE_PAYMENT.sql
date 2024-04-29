--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LINE_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LINE_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: OEXFLPMS.pls 120.2 2005/09/16 09:05:09 ksurendr noship $ */

--R12 CC Encryption
--The table types are introduced to handle
--change attributes for multiple attributes
--in a single call
TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE Varchar2_Tbl_Type IS TABLE OF Varchar2(2000)
    INDEX BY BINARY_INTEGER;


--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   x_payment_number                OUT NOCOPY NUMBER
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_header_id                     OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_check_number                  OUT NOCOPY VARCHAR2
,   x_credit_card_approval_code     OUT NOCOPY VARCHAR2
,   x_credit_card_approval_date     OUT NOCOPY DATE
,   x_credit_card_code              OUT NOCOPY VARCHAR2
,   x_credit_card_expiration_date   OUT NOCOPY DATE
,   x_credit_card_holder_name       OUT NOCOPY VARCHAR2
,   x_credit_card_number            OUT NOCOPY VARCHAR2
,   x_payment_level_code            OUT NOCOPY VARCHAR2
,   x_commitment_applied_amount     OUT NOCOPY NUMBER
,   x_commitment_interfaced_amount  OUT NOCOPY NUMBER
,   x_payment_amount                OUT NOCOPY NUMBER
,   x_payment_collection_event      OUT NOCOPY VARCHAR2
,   x_payment_trx_id                OUT NOCOPY NUMBER
,   x_payment_type_code             OUT NOCOPY VARCHAR2
,   x_payment_set_id                OUT NOCOPY NUMBER
,   x_prepaid_amount                OUT NOCOPY NUMBER
,   x_receipt_method_id             OUT NOCOPY NUMBER
,   x_tangible_id                   OUT NOCOPY VARCHAR2
,   x_receipt_method                 OUT NOCOPY VARCHAR2
,   x_pmt_collection_event_name  OUT NOCOPY VARCHAR2
,   x_payment_type                  OUT NOCOPY VARCHAR2
,   x_defer_processing_flag         OUT NOCOPY VARCHAR2
,   x_trxn_extension_id             OUT NOCOPY NUMBER  --R12 process order api changes
,   x_instrument_security_code OUT NOCOPY VARCHAR2 --R12 CC Encryption
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type --R12 CC Encryption
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type --R12 CC Encryption
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
,   p_context                       IN  VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_payment_number                OUT NOCOPY NUMBER
,   x_header_id                     OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_check_number                  OUT NOCOPY VARCHAR2
,   x_credit_card_approval_code     OUT NOCOPY VARCHAR2
,   x_credit_card_approval_date     OUT NOCOPY DATE
,   x_credit_card_code              OUT NOCOPY VARCHAR2
,   x_credit_card_expiration_date   OUT NOCOPY DATE
,   x_credit_card_holder_name       OUT NOCOPY VARCHAR2
,   x_credit_card_number            OUT NOCOPY VARCHAR2
,   x_payment_level_code            OUT NOCOPY VARCHAR2
,   x_commitment_applied_amount     OUT NOCOPY NUMBER
,   x_commitment_interfaced_amount  OUT NOCOPY NUMBER
,   x_payment_amount                OUT NOCOPY NUMBER
,   x_payment_collection_event      OUT NOCOPY VARCHAR2
,   x_payment_trx_id                OUT NOCOPY NUMBER
,   x_payment_type_code             OUT NOCOPY VARCHAR2
,   x_payment_set_id                OUT NOCOPY NUMBER
,   x_prepaid_amount                OUT NOCOPY NUMBER
,   x_receipt_method_id             OUT NOCOPY NUMBER
,   x_tangible_id                   OUT NOCOPY VARCHAR2
,   x_receipt_method                 OUT NOCOPY VARCHAR2
,   x_pmt_collection_event_name  OUT NOCOPY VARCHAR2
,   x_payment_type                  OUT NOCOPY VARCHAR2
,   x_defer_processing_flag         OUT NOCOPY VARCHAR2
,   x_instrument_security_code OUT NOCOPY VARCHAR2 --R12 CC Encryption
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
,   x_program_id                    OUT NOCOPY NUMBER
,   x_program_application_id        OUT NOCOPY NUMBER
,   x_program_update_date           OUT NOCOPY DATE
,   x_request_id                    OUT NOCOPY NUMBER
,   x_lock_control                  OUT NOCOPY NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--


PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_lock_control                  IN  NUMBER
);

--  Procedure Copy_attribute_to_Rec
--  R12 CC Encryption
PROCEDURE Copy_Attribute_To_Rec
(   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   x_line_payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Tbl_Type
,   x_old_line_payment_tbl        IN OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Tbl_Type
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
,   p_context                       IN  VARCHAR2
);



END OE_OE_Form_Line_Payment;

 

/
