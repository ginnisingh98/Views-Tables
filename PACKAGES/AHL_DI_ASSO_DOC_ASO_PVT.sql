--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOC_ASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOC_ASO_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDASS.pls 115.12 2002/12/03 12:30:39 pbarman noship $ */
-- Name        : association_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the document associations

TYPE association_rec IS RECORD
 (
  DOC_TITLE_ASSO_ID     NUMBER         := FND_API.G_MISS_NUM,
  DOCUMENT_ID           NUMBER         := FND_API.G_MISS_NUM,
  DOC_REVISION_ID       NUMBER         := FND_API.G_MISS_NUM,
  USE_LATEST_REV_FLAG   VARCHAR2(1)    := FND_API.G_MISS_CHAR,
  ASO_OBJECT_TYPE_CODE  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  ASO_OBJECT_ID         NUMBER         := FND_API.G_MISS_NUM,
  SERIAL_NO             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  SOURCE_LANG           VARCHAR2(4)    := FND_API.G_MISS_CHAR,
  LANGUAGE              VARCHAR2(4)    := FND_API.G_MISS_CHAR,
  CHAPTER               VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  SECTION               VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  SUBJECT               VARCHAR2(240)  := FND_API.G_MISS_CHAR,
  PAGE                  VARCHAR2(5)    := FND_API.G_MISS_CHAR,
  FIGURE                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  NOTE                  VARCHAR2(2000) := FND_API.G_MISS_CHAR,
  SOURCE_REF_CODE       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  OBJECT_VERSION_NUMBER NUMBER         := FND_API.G_MISS_NUM,
  ATTRIBUTE_CATEGORY     VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  ATTRIBUTE1             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE2             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE3             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE4             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE5             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE6             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE7             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE8             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE9             VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE10            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE11            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE12            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE13            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE14            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  ATTRIBUTE15            VARCHAR2(150) := FND_API.G_MISS_CHAR,
  DELETE_FLAG            VARCHAR2(1)   := 'N'
  );

 --Declare table type
 TYPE association_tbl IS TABLE OF association_rec INDEX BY BINARY_INTEGER;

 -- Procedure to create association record
 PROCEDURE CREATE_ASSOCIATION
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

--Procedure to update, removes association record
PROCEDURE MODIFY_ASSOCIATION
(
 p_api_version                IN      NUMBER    := 1.0           ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl          IN  OUT NOCOPY association_tbl              ,
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

END AHL_DI_ASSO_DOC_ASO_PVT;

 

/
