--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOC_ASO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOC_ASO_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDASS.pls 115.13 2002/12/03 12:28:29 pbarman noship $ */
TYPE association_rec IS RECORD
 (
  DOC_TITLE_ASSO_ID     NUMBER        := FND_API.G_MISS_NUM,
  DOCUMENT_ID           NUMBER        := FND_API.G_MISS_NUM,
  DOCUMENT_NO           VARCHAR2(80)  := FND_API.G_MISS_CHAR,
  DOC_REVISION_ID       NUMBER        := FND_API.G_MISS_NUM,
  REVISION_NO           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  USE_LATEST_REV_FLAG   VARCHAR2(1)   := FND_API.G_MISS_CHAR,
  ASO_OBJECT_TYPE_CODE  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  ASO_OBJECT_DESC       VARCHAR2(80)  := FND_API.G_MISS_CHAR,
  ASO_OBJECT_ID         NUMBER        := FND_API.G_MISS_NUM,
  SERIAL_NO             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  SOURCE_LANG           VARCHAR2(12)  := FND_API.G_MISS_CHAR,
  CHAPTER               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  SECTION               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  SUBJECT               VARCHAR2(240) := FND_API.G_MISS_CHAR,
  PAGE                  VARCHAR2(5)   := FND_API.G_MISS_CHAR,
  FIGURE                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  NOTE                  VARCHAR2(2000) := FND_API.G_MISS_CHAR,
  SOURCE_REF_CODE       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
  SOURCE_REF_MEAN       VARCHAR2(80)   := FND_API.G_MISS_CHAR,
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
  DELETE_FLAG           VARCHAR2(1)   := 'N'
  );


 TYPE association_tbl IS TABLE OF association_rec INDEX BY BINARY_INTEGER;

 PROCEDURE CREATE_ASSOCIATION
 (
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl            IN  OUT NOCOPY association_tbl       ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);


PROCEDURE MODIFY_ASSOCIATION
(
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl            IN  OUT NOCOPY association_tbl       ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tblm           IN  OUT NOCOPY association_tbl       ,
 p_x_association_tblc           IN  OUT NOCOPY association_tbl       ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);



END AHL_DI_ASSO_DOC_ASO_PUB;

 

/
