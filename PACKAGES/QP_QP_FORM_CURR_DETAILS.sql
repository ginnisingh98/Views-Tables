--------------------------------------------------------
--  DDL for Package QP_QP_FORM_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_CURR_DETAILS" AUTHID CURRENT_USER AS
/* $Header: QPXFCDTS.pls 120.1 2005/06/12 23:48:55 appldev  $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER -- Added by Sunil
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
,   x_conversion_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_conversion_date_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
-- ,   x_conversion_method             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_type               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_fixed_value                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_formula_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_operator               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_value                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_rounding_factor       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_to_currency_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_formula                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_to_currency                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_precedence                    OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_detail_id            IN  NUMBER
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_conversion_date_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
-- ,   x_conversion_method             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_type               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_fixed_value                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_formula_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_operator               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_value                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_rounding_factor       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_to_currency_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_formula                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_to_currency                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_precedence                    OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_detail_id            IN  NUMBER
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
,   p_currency_detail_id            IN  NUMBER
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
,   p_context                       IN  VARCHAR2
,   p_conversion_date               IN  DATE
,   p_conversion_date_type          IN  VARCHAR2
-- ,   p_conversion_method             IN  VARCHAR2
,   p_conversion_type               IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_detail_id            IN  NUMBER
,   p_currency_header_id            IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_fixed_value                   IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_markup_formula_id             IN  NUMBER
,   p_markup_operator               IN  VARCHAR2
,   p_markup_value                  IN  NUMBER
,   p_price_formula_id              IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_rounding_factor               IN  NUMBER
,   p_selling_rounding_factor       IN  NUMBER
,   p_start_date_active             IN  DATE
,   p_to_currency_code              IN  VARCHAR2
,   p_curr_attribute_type           IN  VARCHAR2
,   p_curr_attribute_context        IN  VARCHAR2
,   p_curr_attribute                IN  VARCHAR2
,   p_curr_attribute_value          IN  VARCHAR2
,   p_precedence                    IN  NUMBER
);

END QP_QP_Form_Curr_Details;

 

/
