--------------------------------------------------------
--  DDL for Package QP_QP_FORM_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_LIMIT_BALANCES" AUTHID CURRENT_USER AS
/* $Header: QPXFLMBS.pls 120.1 2005/06/13 03:35:25 appldev  $ */

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
,   x_available_amount              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_consumed_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit_balance_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_multival_attr1_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_value       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reserved_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_balance                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_balance_id              IN  NUMBER
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
,   x_available_amount              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_consumed_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit_balance_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_multival_attr1_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_value       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reserved_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_balance                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_balance_id              IN  NUMBER
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
,   p_limit_balance_id              IN  NUMBER
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
,   p_available_amount              IN  NUMBER
,   p_consumed_amount               IN  NUMBER
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_limit_balance_id              IN  NUMBER
,   p_limit_id                      IN  NUMBER
,   p_multival_attr1_type           IN  VARCHAR2
,   p_multival_attr1_context        IN  VARCHAR2
,   p_multival_attribute1           IN  VARCHAR2
,   p_multival_attr1_value          IN  VARCHAR2
,   p_multival_attr1_datatype       IN  VARCHAR2
,   p_multival_attr2_type           IN  VARCHAR2
,   p_multival_attr2_context        IN  VARCHAR2
,   p_multival_attribute2           IN  VARCHAR2
,   p_multival_attr2_value          IN  VARCHAR2
,   p_multival_attr2_datatype       IN  VARCHAR2
,   p_organization_attr_context     IN  VARCHAR2
,   p_organization_attribute        IN  VARCHAR2
,   p_organization_attr_value       IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_reserved_amount               IN  NUMBER
);

END QP_QP_Form_Limit_Balances;

 

/
