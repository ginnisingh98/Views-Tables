--------------------------------------------------------
--  DDL for Package QP_QP_FORM_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_FORMULA_LINES" AUTHID CURRENT_USER AS
/* $Header: QPXFPFLS.pls 120.1 2005/06/13 04:04:04 appldev  $ */


--  Procedure : Create_Factor_List
--

PROCEDURE Create_Factor_List
(   p_name                          IN  VARCHAR2
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_price_formula_id              IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_numeric_constant              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_line_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_formula_line_type_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_modifier_list_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_step_number                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_modifier_list           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reqd_flag                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_line_id         IN  NUMBER
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
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_numeric_constant              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_line_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_formula_line_type_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_modifier_list_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_step_number                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_modifier_list           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reqd_flag                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_line_id         IN  NUMBER
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
,   p_price_formula_line_id         IN  NUMBER
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
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_end_date_active               IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_numeric_constant              IN  NUMBER
,   p_price_formula_id              IN  NUMBER
,   p_price_formula_line_id         IN  NUMBER
,   p_formula_line_type_code        IN  VARCHAR2
,   p_price_list_line_id            IN  NUMBER
,   p_price_modifier_list_id        IN  NUMBER
,   p_pricing_attribute             IN  VARCHAR2
,   p_pricing_attribute_context     IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_step_number                   IN  NUMBER
,   p_reqd_flag                     IN  VARCHAR2
);

END QP_QP_Form_Formula_Lines;

 

/
