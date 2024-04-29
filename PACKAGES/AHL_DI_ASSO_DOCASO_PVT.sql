--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOCASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOCASO_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDOAS.pls 115.3 2002/12/03 12:31:32 pbarman noship $ */
TYPE association_rec IS RECORD
 (
  ROWID                 VARCHAR2(30),
  DOC_TITLE_ASSO_ID     NUMBER ,
  DOCUMENT_ID           NUMBER ,
  DOCUMENT_NO           VARCHAR2(80)   ,
  DOC_REVISION_ID       NUMBER         ,
  REVISION_NO           VARCHAR2(30)   ,
  USE_LATEST_REV_FLAG   VARCHAR2(1)    ,
  ASO_OBJECT_TYPE_CODE  VARCHAR2(30)   ,
  ASO_OBJECT_DESC       VARCHAR2(80)   ,
  ASO_OBJECT_ID         NUMBER         ,
  SERIAL_NO             VARCHAR2(30)   ,
  SOURCE_LANG           VARCHAR2(12)   ,
  CHAPTER               VARCHAR2(30)   ,
  SECTION               VARCHAR2(30)   ,
  SUBJECT               VARCHAR2(240)  ,
  PAGE                  VARCHAR2(5)    ,
  FIGURE                VARCHAR2(30)   ,
  NOTE                  VARCHAR2(2000) ,
  SOURCE_REF_CODE       VARCHAR2(30)   ,
  SOURCE_REF_MEAN       VARCHAR2(80)   ,
  OBJECT_VERSION_NUMBER NUMBER         ,
  LAST_UPDATE_DATE      DATE           ,
  LAST_UPDATED_BY       NUMBER         ,
  CREATION_DATE         DATE           ,
  CREATED_BY            NUMBER(15)     ,
  LAST_UPDATE_LOGIN     NUMBER(15)     ,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)   ,
  ATTRIBUTE1            VARCHAR2(150)  ,
  ATTRIBUTE2            VARCHAR2(150)  ,
  ATTRIBUTE3            VARCHAR2(150)  ,
  ATTRIBUTE4            VARCHAR2(150)  ,
  ATTRIBUTE5            VARCHAR2(150)  ,
  ATTRIBUTE6            VARCHAR2(150)  ,
  ATTRIBUTE7            VARCHAR2(150)  ,
  ATTRIBUTE8            VARCHAR2(150)  ,
  ATTRIBUTE9            VARCHAR2(150)  ,
  ATTRIBUTE10           VARCHAR2(150)  ,
  ATTRIBUTE11           VARCHAR2(150)  ,
  ATTRIBUTE12           VARCHAR2(150)  ,
  ATTRIBUTE13           VARCHAR2(150)  ,
  ATTRIBUTE14           VARCHAR2(150)  ,
  ATTRIBUTE15           VARCHAR2(150)  ,
  DML_OPERATION         VARCHAR2(1)   := 'N'
  );

TYPE association_tbl IS TABLE OF association_rec INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version                  IN  		NUMBER    := 1.0,
 p_init_msg_list                IN  		VARCHAR2  := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2  := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2,
 x_return_status                OUT 		NOCOPY VARCHAR2,
 x_msg_count                    OUT 		NOCOPY NUMBER,
 x_msg_data                     OUT 		NOCOPY VARCHAR2,
 p_x_association_tbl            IN  OUT NOCOPY association_tbl
 );

END AHL_DI_ASSO_DOCASO_PVT;

 

/
