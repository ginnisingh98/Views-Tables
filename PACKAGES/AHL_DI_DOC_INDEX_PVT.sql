--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_INDEX_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDIXS.pls 120.0.12010000.2 2010/01/28 13:12:31 pekambar ship $ */
-- Name        : doc_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the document
TYPE doc_rec IS RECORD
 (
  DOCUMENT_ID           NUMBER        ,
  SOURCE_PARTY_ID       NUMBER        ,
  DOC_TYPE_CODE         VARCHAR2(30)  ,
  DOC_SUB_TYPE_CODE     VARCHAR2(30)  ,
  DOCUMENT_NO           VARCHAR2(30)  ,
  OPERATOR_CODE         VARCHAR2(30)  ,
  PRODUCT_TYPE_CODE     VARCHAR2(30)  ,
  SUBSCRIBE_AVAIL_FLAG  VARCHAR2(1)   ,
  SUBSCRIBE_TO_FLAG     VARCHAR2(1)   ,
  --DOCUMENT_TITLE        VARCHAR2(80)  ,
  DOCUMENT_TITLE        VARCHAR2(240)  ,
  LANGUAGE              VARCHAR2(4)   ,
  SOURCE_LANG           VARCHAR2(4)   ,
  OBJECT_VERSION_NUMBER NUMBER        ,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)  ,
  ATTRIBUTE1            VARCHAR2(150) ,
  ATTRIBUTE2            VARCHAR2(150) ,
  ATTRIBUTE3            VARCHAR2(150) ,
  ATTRIBUTE4            VARCHAR2(150) ,
  ATTRIBUTE5            VARCHAR2(150) ,
  ATTRIBUTE6            VARCHAR2(150) ,
  ATTRIBUTE7            VARCHAR2(150) ,
  ATTRIBUTE8            VARCHAR2(150) ,
  ATTRIBUTE9            VARCHAR2(150) ,
  ATTRIBUTE10           VARCHAR2(150) ,
  ATTRIBUTE11           VARCHAR2(150) ,
  ATTRIBUTE12           VARCHAR2(150) ,
  ATTRIBUTE13           VARCHAR2(150) ,
  ATTRIBUTE14           VARCHAR2(150) ,
  ATTRIBUTE15           VARCHAR2(150) ,
  DELETE_FLAG           VARCHAR2(1)   := 'N'
  );
-- Name        : supplier_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the suppliers
TYPE supplier_rec IS RECORD
 (
  SUPPLIER_DOCUMENT_ID  NUMBER        ,
  SUPPLIER_ID           NUMBER        ,
  DOCUMENT_ID           NUMBER        ,
  PREFERENCE_CODE       VARCHAR2(30)  ,
  OBJECT_VERSION_NUMBER NUMBER        ,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)  ,
  ATTRIBUTE1            VARCHAR2(150) ,
  ATTRIBUTE2            VARCHAR2(150) ,
  ATTRIBUTE3            VARCHAR2(150) ,
  ATTRIBUTE4            VARCHAR2(150) ,
  ATTRIBUTE5            VARCHAR2(150) ,
  ATTRIBUTE6            VARCHAR2(150) ,
  ATTRIBUTE7            VARCHAR2(150) ,
  ATTRIBUTE8            VARCHAR2(150) ,
  ATTRIBUTE9            VARCHAR2(150) ,
  ATTRIBUTE10           VARCHAR2(150) ,
  ATTRIBUTE11           VARCHAR2(150) ,
  ATTRIBUTE12           VARCHAR2(150) ,
  ATTRIBUTE13           VARCHAR2(150) ,
  ATTRIBUTE14           VARCHAR2(150) ,
  ATTRIBUTE15           VARCHAR2(150) ,
  SOURCE                VARCHAR2(5)   ,
  DELETE_FLAG           VARCHAR2(1)   := 'N'
 );
-- Name        : recipient_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the recipients
TYPE recipient_rec IS RECORD
 (
  RECIPIENT_DOCUMENT_ID  NUMBER       ,
  RECIPIENT_PARTY_ID     NUMBER       ,
  RECIPIENT_PARTY_NUMBER   VARCHAR2(80) ,
  DOCUMENT_ID            NUMBER       ,
  OBJECT_VERSION_NUMBER NUMBER        ,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)  ,
  ATTRIBUTE1            VARCHAR2(150) ,
  ATTRIBUTE2            VARCHAR2(150) ,
  ATTRIBUTE3            VARCHAR2(150) ,
  ATTRIBUTE4            VARCHAR2(150) ,
  ATTRIBUTE5            VARCHAR2(150) ,
  ATTRIBUTE6            VARCHAR2(150) ,
  ATTRIBUTE7            VARCHAR2(150) ,
  ATTRIBUTE8            VARCHAR2(150) ,
  ATTRIBUTE9            VARCHAR2(150) ,
  ATTRIBUTE10           VARCHAR2(150) ,
  ATTRIBUTE11           VARCHAR2(150) ,
  ATTRIBUTE12           VARCHAR2(150) ,
  ATTRIBUTE13           VARCHAR2(150) ,
  ATTRIBUTE14           VARCHAR2(150) ,
  ATTRIBUTE15           VARCHAR2(150) ,
  DELETE_FLAG           VARCHAR2(1)   := 'N'
 );

-- Defiene the Table Type for Document Indexes and its associated
-- Suppliers and Recipients
TYPE document_tbl IS TABLE OF doc_rec INDEX BY BINARY_INTEGER;
TYPE supplier_tbl IS TABLE OF supplier_rec INDEX BY BINARY_INTEGER;
TYPE recipient_tbl IS TABLE OF recipient_rec INDEX BY BINARY_INTEGER;
 FUNCTION get_product_install_status (x_product_name IN VARCHAR2)
 RETURN VARCHAR2 ;

--Procedure to create document record and its associated suppliers,
--recipients,subscriptions, revisions ,revision copies

PROCEDURE CREATE_DOCUMENT
 (
 p_api_version               IN     NUMBER    := 1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl            IN OUT NOCOPY Document_Tbl           ,
 p_x_supplier_tbl            IN OUT NOCOPY Supplier_Tbl           ,
 p_x_recipient_tbl           IN OUT NOCOPY Recipient_Tbl          ,
 x_return_status                OUT NOCOPY VARCHAR2                      ,
 x_msg_count                    OUT NOCOPY NUMBER                        ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );
--Procedure to update document record and its associated suppliers,
--recipients,subscriptions, revisions ,revision copies

PROCEDURE MODIFY_DOCUMENT
(
 p_api_version               IN     NUMBER    := 1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl            IN OUT NOCOPY document_tbl           ,
 p_x_supplier_tbl            IN OUT NOCOPY Supplier_Tbl           ,
 p_x_recipient_tbl           IN OUT NOCOPY Recipient_Tbl          ,
 x_return_status                OUT NOCOPY VARCHAR2                      ,
 x_msg_count                    OUT NOCOPY NUMBER                        ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );

--Procedure to Create Supplier Record for an associated document
PROCEDURE CREATE_SUPPLIER
 (
 p_api_version              IN      NUMBER    := 1.0               ,
 p_init_msg_list            IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                   IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only            IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level         IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_supplier_tbl           IN  OUT NOCOPY supplier_tbl              ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

--Procedure to Update Supplier Record for an associated document
PROCEDURE MODIFY_SUPPLIER
(
 p_api_version               IN     NUMBER    := 1.0               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_supplier_tbl              IN     supplier_tbl                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

--Procedure to Remove Supplier Record for an associated document
PROCEDURE DELETE_SUPPLIER
(
 p_api_version                IN     NUMBER    := 1.0               ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_supplier_rec               IN     supplier_rec                     ,
 x_return_status                 OUT NOCOPY VARCHAR2                         ,
 x_msg_count                     OUT NOCOPY NUMBER                           ,
 x_msg_data                      OUT NOCOPY VARCHAR2);

--Procedure to Create Recipient Record for an associated document
 PROCEDURE CREATE_RECIPIENT
 (
 p_api_version                IN     NUMBER    := 1.0               ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_recipient_tbl            IN OUT NOCOPY recipient_tbl             ,
 x_return_status                 OUT NOCOPY VARCHAR2                         ,
 x_msg_count                     OUT NOCOPY NUMBER                           ,
 x_msg_data                      OUT NOCOPY VARCHAR2);

--Procedure to Update Recipient Record for an associated document
PROCEDURE MODIFY_RECIPIENT
(
 p_api_version                IN  NUMBER    := 1.0               ,
 p_init_msg_list              IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_recipient_tbl              IN OUT NOCOPY recipient_tbl          ,
 x_return_status                 OUT NOCOPY VARCHAR2                      ,
 x_msg_count                     OUT NOCOPY NUMBER                        ,
 x_msg_data                      OUT NOCOPY VARCHAR2);

--Procedure to Remove Recipient Record for an associated document
PROCEDURE DELETE_RECIPIENT
(
 p_api_version                IN    NUMBER    := 1.0               ,
 p_init_msg_list              IN    VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN    VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN    VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_recipient_rec              IN    recipient_rec                    ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

END AHL_DI_DOC_INDEX_PVT;

/
