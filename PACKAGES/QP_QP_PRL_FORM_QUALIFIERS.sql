--------------------------------------------------------
--  DDL for Package QP_QP_PRL_FORM_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_PRL_FORM_QUALIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXFPLQS.pls 120.2 2005/08/31 18:06:30 srashmi noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_qualifier_rule_id             IN  NUMBER := FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER := FND_API.G_MISS_NUM
,   p_qualifier_context             IN  VARCHAR2 := FND_API.G_MISS_CHAR
,   p_qualifier_attribute           IN  VARCHAR2 := FND_API.G_MISS_CHAR
,   p_qualifier_attr_value          IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value_to       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_datatype            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier_date_format         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_qualifier_number_format       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_precedence          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
--,   x_comparison_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualify_hier_descendent_flag OUT NOCOPY VARCHAR2  -- Added for TCA
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
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
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value_to       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_datatype            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier_date_format         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_qualifier_number_format       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_precedence          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
--,   x_comparison_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualify_hier_descendent_flag OUT NOCOPY VARCHAR2 -- Added for TCA
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
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
,   p_qualifier_id                  IN  NUMBER
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
,   p_comparison_operator_code      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_created_from_rule_id          IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_end_date_active               IN  DATE
,   p_excluder_flag                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_qualifier_attribute           IN  VARCHAR2
,   p_qualifier_attr_value          IN  VARCHAR2
,   p_qualifier_attr_value_to       IN  VARCHAR2
,   p_qualifier_context             IN  VARCHAR2
,   p_qualifier_datatype            IN  VARCHAR2
--,   p_qualifier_date_format         IN  VARCHAR2
,   p_qualifier_grouping_no         IN  NUMBER
,   p_qualifier_id                  IN  NUMBER
--,   p_qualifier_number_format       IN  VARCHAR2
,   p_qualifier_precedence          IN  NUMBER
,   p_qualifier_rule_id             IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_start_date_active             IN  DATE
,   p_qualify_hier_descendent_flag IN  VARCHAR2 -- Added for TCA
);

--spgopal  added out parameters to error out when copy failed
--and also display the number of qualifier records processed
PROCEDURE Get_Rules(p_qualifier_rule_id IN NUMBER,
                    p_list_header_id IN NUMBER,
				p_list_line_id IN NUMBER := Null,
				p_group_condition IN VARCHAR2 DEFAULT 'AND',
				x_processed_qual_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
				x_msg_count	OUT NOCOPY /* file.sql.39 change */ NUMBER,
				x_msg_data	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
);


Procedure Delete_All_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END QP_QP_PRL_Form_Qualifiers;

 

/
