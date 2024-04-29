--------------------------------------------------------
--  DDL for Package QP_QP_FORM_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_MODIFIER_LIST" AUTHID CURRENT_USER AS
/* $Header: QPXFMLHS.pls 120.2 2005/06/20 22:47:30 appldev ship $ */

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
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_gsa_indicator                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_type_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_parent_list_header_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active_first       OUT NOCOPY /* file.sql.39 change */ DATE
,   x_end_date_active_first         OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_first_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active_second      OUT NOCOPY /* file.sql.39 change */ DATE
,   x_global_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active_second        OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_second_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ask_for_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_source_code		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_orig_system_header_ref        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
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
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_gsa_indicator                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_type_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_parent_list_header_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active_first       OUT NOCOPY /* file.sql.39 change */ DATE
,   x_end_date_active_first         OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_first_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active_second      OUT NOCOPY /* file.sql.39 change */ DATE
,   x_global_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active_second        OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_second_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ask_for_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_source_code		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_orig_system_header_ref        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
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
,   p_list_header_id                IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       lock_Row
--



PROCEDURE Create_GSA_Qual(p_list_header_id IN NUMBER,
			p_list_line_id In NUMBER,
			p_qualifier_type IN VARCHAR2,
	          x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


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
,   p_automatic_flag                IN  VARCHAR2
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_code                 IN  VARCHAR2
,   p_discount_lines_flag           IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_freight_terms_code            IN  VARCHAR2
,   p_gsa_indicator                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_type_code                IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_prorate_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_rounding_factor               IN  NUMBER
,   p_ship_method_code              IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_terms_id                      IN  NUMBER
,   p_source_system_code            IN VARCHAR2
,   p_pte_code                      IN VARCHAR2
,   p_active_flag                   IN VARCHAR2
,   p_parent_list_header_id         IN NUMBER
,   p_start_date_active_first       IN  DATE
,   p_end_date_active_first         IN  DATE
,   p_active_date_first_type        IN  VARCHAR2
,   p_start_date_active_second      IN  DATE
,   p_global_flag                   IN  VARCHAR2
,   p_end_date_active_second        IN  DATE
,   p_active_date_second_type       IN  VARCHAR2
,   p_ask_for_flag                  IN  VARCHAR2
,   p_list_source_code              IN VARCHAR2 := NULL
,   p_orig_system_header_ref        IN VARCHAR2 := NULL
,   p_shareable_flag                IN VARCHAR2 := NULL
--added for MOAC
,   p_org_id                        IN NUMBER
);

-- added by svdeshmu for delayed request on feb 24 ,00

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
);


Procedure Delete_All_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- end of additions by svdeshmu







END QP_QP_Form_Modifier_List;

 

/
