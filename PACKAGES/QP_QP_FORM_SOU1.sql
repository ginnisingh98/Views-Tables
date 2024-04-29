--------------------------------------------------------
--  DDL for Package QP_QP_FORM_SOU1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_SOU1" AUTHID CURRENT_USER AS
/* $Header: QPFSOU2S.pls 120.1 2005/06/09 21:47:05 appldev  $ */

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
,   x_attribute_sourcing_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_attribute_sourcing_level      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_application_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_request_type_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_sourcing_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_value_string           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_user_sourcing_type            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_value_string             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute_sourcing            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_request_type                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_attribute_sourcing_id         IN  NUMBER
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
,   x_attribute_sourcing_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_attribute_sourcing_level      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_application_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_request_type_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_sourcing_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_value_string           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_user_sourcing_type            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_value_string             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute_sourcing            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_request_type                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_attribute_sourcing_id         IN  NUMBER
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
,   p_attribute_sourcing_id         IN  NUMBER
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
,   p_attribute_sourcing_id         IN  NUMBER
,   p_attribute_sourcing_level      IN  VARCHAR2
,   p_application_id                IN  NUMBER
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_enabled_flag                  IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_type_code             IN  VARCHAR2
,   p_seeded_flag                   IN  VARCHAR2
,   p_seeded_sourcing_type          IN  VARCHAR2
,   p_seeded_value_string           IN  VARCHAR2
,   p_segment_id                    IN  NUMBER
,   p_user_sourcing_type            IN  VARCHAR2
,   p_user_value_string             IN  VARCHAR2
);

END QP_QP_Form_Sou1;

 

/
