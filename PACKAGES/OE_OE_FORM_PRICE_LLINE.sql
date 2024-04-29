--------------------------------------------------------
--  DDL for Package OE_OE_FORM_PRICE_LLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_PRICE_LLINE" AUTHID CURRENT_USER AS
/* $Header: OEXFPLLS.pls 120.1 2005/06/09 00:24:53 appldev  $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_method_code                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute10           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute11           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute12           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute13           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute14           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute15           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute5            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute6            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute7            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute8            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute9            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_context               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE  -- Added by Geresh
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_list_line_id            IN  NUMBER
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_method_code                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute10           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute11           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute12           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute13           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute14           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute15           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute5            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute6            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute7            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute8            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute9            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_context               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE  -- Added by Geresh
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_list_line_id            IN  NUMBER
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
,   p_price_list_line_id            IN  NUMBER
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
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_customer_item_id              IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_price                    IN  NUMBER
,   p_method_code                   IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_price_list_line_id            IN  NUMBER
,   p_pricing_attribute1            IN  VARCHAR2
,   p_pricing_attribute10           IN  VARCHAR2
,   p_pricing_attribute11           IN  VARCHAR2
,   p_pricing_attribute12           IN  VARCHAR2
,   p_pricing_attribute13           IN  VARCHAR2
,   p_pricing_attribute14           IN  VARCHAR2
,   p_pricing_attribute15           IN  VARCHAR2
,   p_pricing_attribute2            IN  VARCHAR2
,   p_pricing_attribute3            IN  VARCHAR2
,   p_pricing_attribute4            IN  VARCHAR2
,   p_pricing_attribute5            IN  VARCHAR2
,   p_pricing_attribute6            IN  VARCHAR2
,   p_pricing_attribute7            IN  VARCHAR2
,   p_pricing_attribute8            IN  VARCHAR2
,   p_pricing_attribute9            IN  VARCHAR2
,   p_pricing_context               IN  VARCHAR2
,   p_pricing_rule_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_reprice_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_unit_code                     IN  VARCHAR2
,   p_primary                       IN  VARCHAR2
,   p_list_line_type_code           IN  VARCHAR2
);

END OE_OE_Form_Price_Lline;

 

/
