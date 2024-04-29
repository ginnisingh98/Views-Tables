--------------------------------------------------------
--  DDL for Package AHL_DI_PRO_TYPE_ASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_PRO_TYPE_ASO_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPTAS.pls 115.9 2002/12/03 12:32:13 pbarman noship $ */
-- Name        : doc type association rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of document type and subtype
--               associations

TYPE doc_type_assoc_rec IS RECORD
 (
  DOCUMENT_SUB_TYPE_ID   NUMBER        ,
  DOC_TYPE_CODE          VARCHAR2(30)  ,
  DOC_SUB_TYPE_CODE      VARCHAR2(30)  ,
  ATTRIBUTE_CATEGORY     VARCHAR2(30)  ,
  ATTRIBUTE1             VARCHAR2(150) ,
  ATTRIBUTE2             VARCHAR2(150) ,
  ATTRIBUTE3             VARCHAR2(150) ,
  ATTRIBUTE4             VARCHAR2(150) ,
  ATTRIBUTE5             VARCHAR2(150) ,
  ATTRIBUTE6             VARCHAR2(150) ,
  ATTRIBUTE7             VARCHAR2(150) ,
  ATTRIBUTE8             VARCHAR2(150) ,
  ATTRIBUTE9             VARCHAR2(150) ,
  ATTRIBUTE10            VARCHAR2(150) ,
  ATTRIBUTE11            VARCHAR2(150) ,
  ATTRIBUTE12            VARCHAR2(150) ,
  ATTRIBUTE13            VARCHAR2(150) ,
  ATTRIBUTE14            VARCHAR2(150) ,
  ATTRIBUTE15            VARCHAR2(150) ,
  OBJECT_VERSION_NUMBER  NUMBER        ,
  DELETE_FLAG            VARCHAR2(1)   := 'N'
  );

 --Declare table type
 TYPE doc_type_assoc_tbl IS TABLE OF doc_type_assoc_rec
 INDEX BY BINARY_INTEGER;

-- Procedure to create doc type associations for document index
 PROCEDURE CREATE_DOC_TYPE_ASSOC
 (
 p_api_version              IN      NUMBER    := 1.0              ,
 p_init_msg_list            IN      VARCHAR2  := FND_API.G_TRUE     ,
 p_commit                   IN      VARCHAR2  := FND_API.G_FALSE    ,
 p_validate_only            IN      VARCHAR2  := FND_API.G_TRUE     ,
 p_validation_level         IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl     IN  OUT NOCOPY    doc_type_assoc_tbl    ,
 x_return_status                OUT NOCOPY VARCHAR2                        ,
 x_msg_count                    OUT NOCOPY NUMBER                          ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

-- Procedure to update and delete doc type associations for document index
PROCEDURE MODIFY_DOC_TYPE_ASSOC
(
 p_api_version              IN      NUMBER    := 1.0           ,
 p_init_msg_list            IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                   IN      VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only            IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level         IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl     IN  OUT NOCOPY doc_type_assoc_tbl    ,
 x_return_status                    OUT NOCOPY VARCHAR2                 ,
 x_msg_count                        OUT NOCOPY NUMBER                   ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

END AHL_DI_PRO_TYPE_ASO_PVT;

 

/
