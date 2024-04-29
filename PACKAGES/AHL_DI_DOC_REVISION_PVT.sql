--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_REVISION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDORS.pls 120.0.12010000.2 2010/01/11 07:09:23 snarkhed ship $ */

-- Name        : revision_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the revision
TYPE revision_rec IS RECORD
 (
  DOC_REVISION_ID       NUMBER        ,
  DOCUMENT_ID           NUMBER        ,
  REVISION_NO           VARCHAR2(30)  ,
  REVISION_TYPE_CODE    VARCHAR2(30)  ,
  REVISION_STATUS_CODE  VARCHAR2(30)  ,
  REVISION_DATE         DATE          ,
  APPROVED_BY_PARTY_ID  NUMBER        ,
  APPROVED_DATE         DATE          ,
  EFFECTIVE_DATE        DATE          ,
  OBSOLETE_DATE         DATE          ,
  ISSUE_DATE            DATE          ,
  RECEIVED_DATE         DATE          ,
  URL                   VARCHAR2(240) ,
  MEDIA_TYPE_CODE       VARCHAR2(30)  ,
  VOLUME                VARCHAR2(150) ,
  ISSUE                 VARCHAR2(30)  ,
  ISSUE_NUMBER          NUMBER        ,
  LANGUAGE              VARCHAR2(4)   ,
  SOURCE_LANG           VARCHAR2(4)   ,
  COMMENTS              VARCHAR2(2000),
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
  DELETE_FLAG           VARCHAR2(1)    := 'N'  );

 -- Declare table type
 TYPE revision_tbl IS TABLE OF revision_rec INDEX BY BINARY_INTEGER;

-- Procedure to create revision for an associated document
 PROCEDURE CREATE_REVISION
 (
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN OUT NOCOPY revision_tbl              ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

-- Procedure to modify revision for an associated document
PROCEDURE MODIFY_REVISION
(
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN     revision_tbl                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

-- Procedure to delete revision for an associated document
PROCEDURE DELETE_REVISION
(
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN     revision_tbl                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

-- FP #8410484
 PROCEDURE UPDATE_ASSOCIATIONS_CONCURRENT
 (
	errbuf	OUT NOCOPY VARCHAR2,
	retcode	OUT NOCOPY NUMBER,
	p_api_version IN NUMBER		:=1.0
 );

END AHL_DI_DOC_REVISION_PVT;

/
