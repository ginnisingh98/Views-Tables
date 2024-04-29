--------------------------------------------------------
--  DDL for Package OE_OE_FORM_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_CONTRACT" AUTHID CURRENT_USER AS
/* $Header: OEXFPCTS.pls 115.0 99/07/15 19:22:36 porting shi $ */

PROCEDURE Get_Startup_Values
(Item_Id_Flex_Code         IN VARCHAR2,
 Item_Id_Flex_Num          OUT NUMBER);

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   x_agreement_id                  OUT NUMBER
,   x_attribute1                    OUT VARCHAR2
,   x_attribute10                   OUT VARCHAR2
,   x_attribute11                   OUT VARCHAR2
,   x_attribute12                   OUT VARCHAR2
,   x_attribute13                   OUT VARCHAR2
,   x_attribute14                   OUT VARCHAR2
,   x_attribute15                   OUT VARCHAR2
,   x_attribute2                    OUT VARCHAR2
,   x_attribute3                    OUT VARCHAR2
,   x_attribute4                    OUT VARCHAR2
,   x_attribute5                    OUT VARCHAR2
,   x_attribute6                    OUT VARCHAR2
,   x_attribute7                    OUT VARCHAR2
,   x_attribute8                    OUT VARCHAR2
,   x_attribute9                    OUT VARCHAR2
,   x_context                       OUT VARCHAR2
,   x_discount_id                   OUT NUMBER
,   x_last_updated_by               OUT NUMBER
,   x_price_list_id                 OUT NUMBER
,   x_pricing_contract_id           OUT NUMBER
,   x_agreement                     OUT VARCHAR2
,   x_discount                      OUT VARCHAR2
,   x_price_list                    OUT VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
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
,   x_agreement_id                  OUT NUMBER
,   x_attribute1                    OUT VARCHAR2
,   x_attribute10                   OUT VARCHAR2
,   x_attribute11                   OUT VARCHAR2
,   x_attribute12                   OUT VARCHAR2
,   x_attribute13                   OUT VARCHAR2
,   x_attribute14                   OUT VARCHAR2
,   x_attribute15                   OUT VARCHAR2
,   x_attribute2                    OUT VARCHAR2
,   x_attribute3                    OUT VARCHAR2
,   x_attribute4                    OUT VARCHAR2
,   x_attribute5                    OUT VARCHAR2
,   x_attribute6                    OUT VARCHAR2
,   x_attribute7                    OUT VARCHAR2
,   x_attribute8                    OUT VARCHAR2
,   x_attribute9                    OUT VARCHAR2
,   x_context                       OUT VARCHAR2
,   x_discount_id                   OUT NUMBER
,   x_last_updated_by               OUT NUMBER
,   x_price_list_id                 OUT NUMBER
,   x_pricing_contract_id           OUT NUMBER
,   x_agreement                     OUT VARCHAR2
,   x_discount                      OUT VARCHAR2
,   x_price_list                    OUT VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
,   x_creation_date                 OUT DATE
,   x_created_by                    OUT NUMBER
,   x_last_update_date              OUT DATE
,   x_last_updated_by               OUT NUMBER
,   x_last_update_login             OUT NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
);

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_agreement_id                  IN  NUMBER
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
,   p_discount_id                   IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_price_list_id                 IN  NUMBER
,   p_pricing_contract_id           IN  NUMBER
);

PROCEDURE Create_Revision
(   l_Agreement_Id                  IN  NUMBER
);

END OE_OE_Form_Contract;

 

/
