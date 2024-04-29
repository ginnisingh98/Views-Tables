--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOC_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOC_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDAGS.pls 115.0 2003/07/02 11:45:49 pbarman noship $ */
-- Name        : association_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the document associations

TYPE association_rec IS RECORD
(
  DOC_TITLE_ASSO_ID     NUMBER         := NULL,
  DOCUMENT_ID           NUMBER         := NULL,
  DOC_REVISION_ID       NUMBER         := NULL,
  USE_LATEST_REV_FLAG   VARCHAR2(1)    := NULL,
  ASO_OBJECT_TYPE_CODE  VARCHAR2(30)   := NULL,
  ASO_OBJECT_ID         NUMBER         := NULL,
  SERIAL_NO             VARCHAR2(30)   := NULL,
  SOURCE_LANG           VARCHAR2(4)    := NULL,
  LANGUAGE              VARCHAR2(4)    := NULL,
  CHAPTER               VARCHAR2(30)   := NULL,
  SECTION               VARCHAR2(30)   := NULL,
  SUBJECT               VARCHAR2(240)  := NULL,
  PAGE                  VARCHAR2(5)    := NULL,
  FIGURE                VARCHAR2(30)   := NULL,
  NOTE                  VARCHAR2(2000) := NULL,
  SOURCE_REF_CODE       VARCHAR2(30)   := NULL,
  OBJECT_VERSION_NUMBER NUMBER         := NULL,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)  := NULL,
  ATTRIBUTE1            VARCHAR2(150) := NULL,
  ATTRIBUTE2            VARCHAR2(150) := NULL,
  ATTRIBUTE3            VARCHAR2(150) := NULL,
  ATTRIBUTE4            VARCHAR2(150) := NULL,
  ATTRIBUTE5            VARCHAR2(150) := NULL,
  ATTRIBUTE6            VARCHAR2(150) := NULL,
  ATTRIBUTE7            VARCHAR2(150) := NULL,
  ATTRIBUTE8            VARCHAR2(150) := NULL,
  ATTRIBUTE9            VARCHAR2(150) := NULL,
  ATTRIBUTE10           VARCHAR2(150) := NULL,
  ATTRIBUTE11           VARCHAR2(150) := NULL,
  ATTRIBUTE12           VARCHAR2(150) := NULL,
  ATTRIBUTE13           VARCHAR2(150) := NULL,
  ATTRIBUTE14           VARCHAR2(150) := NULL,
  ATTRIBUTE15           VARCHAR2(150) := NULL,
  DML_OPERATION         VARCHAR2(1)
);

 --Declare table type
 TYPE association_tbl IS TABLE OF association_rec INDEX BY BINARY_INTEGER;

 -- Procedure to create association record
 PROCEDURE PROCESS_ASSOCIATION
 (
 p_api_version                IN      NUMBER    := 1.0           ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl          IN  OUT NOCOPY association_tbl       ,
 x_return_status                  OUT NOCOPY VARCHAR2                     ,
 x_msg_count                      OUT NOCOPY NUMBER                       ,
 x_msg_data                       OUT NOCOPY VARCHAR2);

--Procedure to copy new association record
Procedure COPY_ASSOCIATION
(
 p_api_version                IN      NUMBER    := 1.0           ,
 p_init_msg_list              IN      VARCHAR2  := Fnd_Api.G_TRUE  ,
 p_commit                     IN      VARCHAR2  := Fnd_Api.G_FALSE ,
 p_validate_only              IN      VARCHAR2  := Fnd_Api.G_TRUE  ,
 p_validation_level           IN      NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
 p_from_object_id             IN      NUMBER,
 p_from_object_type           IN      VARCHAR2,
 p_to_object_id               IN      NUMBER,
 p_to_object_type             IN      VARCHAR2,
 x_return_status                  OUT NOCOPY VARCHAR2                     ,
 x_msg_count                      OUT NOCOPY NUMBER                       ,
 x_msg_data                       OUT NOCOPY VARCHAR2);


 -- Procedure to delete all associations to a particular ASO object
 Procedure DELETE_ALL_ASSOCIATIONS
 (
  p_api_version                IN      NUMBER    := 1.0           ,
  p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE  ,
  p_commit                     IN      VARCHAR2  := FND_API.G_FALSE ,
  p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE  ,
  p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_aso_object_type_code       IN      VARCHAR2 ,
  p_aso_object_id              IN      NUMBER ,
  x_return_status                  OUT NOCOPY VARCHAR2                     ,
  x_msg_count                      OUT NOCOPY NUMBER                       ,
  x_msg_data                       OUT NOCOPY VARCHAR2


 );


END AHL_DI_ASSO_DOC_GEN_PVT;

 

/
