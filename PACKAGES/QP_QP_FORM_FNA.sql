--------------------------------------------------------
--  DDL for Package QP_QP_FORM_FNA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_FNA" AUTHID CURRENT_USER AS
/* $Header: QPXFFNAS.pls 120.2 2005/08/18 15:55:44 sfiresto noship $ */

--  Procedure : Check_Enabled_Fnas
--

PROCEDURE Check_Enabled_Fnas(x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_enabled_flag                  OUT NOCOPY VARCHAR2
,   x_functional_area_id            OUT NOCOPY NUMBER
,   x_pte_sourcesystem_fnarea_id    OUT NOCOPY NUMBER
,   x_pte_source_system_id          OUT NOCOPY NUMBER
,   x_seeded_flag                   OUT NOCOPY VARCHAR2
,   x_enabled                       OUT NOCOPY VARCHAR2
,   x_functional_area               OUT NOCOPY VARCHAR2
,   x_pte_sourcesystem_fnarea       OUT NOCOPY VARCHAR2
,   x_pte_source_system             OUT NOCOPY VARCHAR2
,   x_seeded                        OUT NOCOPY VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_pte_sourcesystem_fnarea_id    IN  NUMBER
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
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_enabled_flag                  OUT NOCOPY VARCHAR2
,   x_functional_area_id            OUT NOCOPY NUMBER
,   x_pte_sourcesystem_fnarea_id    OUT NOCOPY NUMBER
,   x_pte_source_system_id          OUT NOCOPY NUMBER
,   x_seeded_flag                   OUT NOCOPY VARCHAR2
,   x_enabled                       OUT NOCOPY VARCHAR2
,   x_functional_area               OUT NOCOPY VARCHAR2
,   x_pte_sourcesystem_fnarea       OUT NOCOPY VARCHAR2
,   x_pte_source_system             OUT NOCOPY VARCHAR2
,   x_seeded                        OUT NOCOPY VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_pte_sourcesystem_fnarea_id    IN  NUMBER
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_pte_sourcesystem_fnarea_id    IN  NUMBER
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
,   p_enabled_flag                  IN  VARCHAR2
,   p_functional_area_id            IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_pte_sourcesystem_fnarea_id    IN  NUMBER
,   p_pte_source_system_id          IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_seeded_flag                   IN  VARCHAR2
);

END QP_QP_Form_Fna;

 

/
