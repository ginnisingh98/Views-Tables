--------------------------------------------------------
--  DDL for Package QP_QP_FORM_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_SEG" AUTHID CURRENT_USER AS
/* $Header: QPXFSEGS.pls 120.2 2005/08/03 07:37:18 srashmi noship $ */

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
,   x_availability_in_basic         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_format_type            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_precedence             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_seeded_segment_name           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_description	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_valueset_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_code               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_application_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_mapping_column        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_format_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_precedence               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_user_segment_name             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_description		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_valueset_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_prc_context                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_valueset               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_valueset                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_required_flag		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_party_hierarchy_enabled_flag       OUT NOCOPY  VARCHAR2   -- Added for TCA
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_segment_id                    IN  NUMBER
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
,   x_availability_in_basic         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_format_type            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_precedence             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_seeded_segment_name           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_description	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_valueset_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_code               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_application_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_mapping_column        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_format_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_precedence               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_user_segment_name             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_description		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_valueset_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_prc_context                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_valueset               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_valueset                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_required_flag		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_party_hierarchy_enabled_flag       OUT NOCOPY VARCHAR2  -- Added for TCA
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_segment_id                    IN  NUMBER
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
,   p_segment_id                    IN  NUMBER
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
,   p_availability_in_basic         IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_prc_context_id                IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_seeded_flag                   IN  VARCHAR2
,   p_seeded_format_type            IN  VARCHAR2
,   p_seeded_precedence             IN  NUMBER
,   p_seeded_segment_name           IN  VARCHAR2
,   p_seeded_description	    IN  VARCHAR2
,   p_seeded_valueset_id            IN  NUMBER
,   p_segment_code                  IN  VARCHAR2
,   p_segment_id                    IN  NUMBER
,   p_application_id                IN  NUMBER
,   p_segment_mapping_column        IN  VARCHAR2
,   p_user_format_type              IN  VARCHAR2
,   p_user_precedence               IN  NUMBER
,   p_user_segment_name             IN  VARCHAR2
,   p_user_description		    IN  VARCHAR2
,   p_user_valueset_id              IN  NUMBER
,   p_required_flag		    IN  VARCHAR2
,   p_party_hierarchy_enabled_flag       IN  VARCHAR2  -- Added for TCA
);

END QP_QP_Form_Seg;

 

/
