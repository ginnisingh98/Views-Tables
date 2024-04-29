--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_REVISION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDORS.pls 120.0 2005/05/25 23:40:50 appldev noship $ */
/*#
 * This is the public interface to create, modify and delete document revisions.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Document Revision
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_DOCUMENT
 */

TYPE revision_rec IS RECORD
 (
  DOC_REVISION_ID       NUMBER        ,
  DOCUMENT_ID           NUMBER        ,
  REVISION_NO           VARCHAR2(30)  ,
  REVISION_TYPE_CODE    VARCHAR2(30)  ,
  REVISION_TYPE_DESC    VARCHAR2(80)  ,
  REVISION_STATUS_CODE  VARCHAR2(30)  ,
  REVISION_STATUS_DESC  VARCHAR2(80)  ,
  REVISION_DATE         DATE          ,
  APPROVED_BY_PARTY_ID  NUMBER        ,
  APPROVED_BY_PTY_NUMBER  VARCHAR2(80)  ,
  APPROVED_BY_PTY_NAME  VARCHAR2(301)  ,
  APPROVED_DATE         DATE          ,
  EFFECTIVE_DATE        DATE          ,
  OBSOLETE_DATE         DATE          ,
  ISSUE_DATE            DATE          ,
  RECEIVED_DATE         DATE          ,
  URL                   VARCHAR2(240) ,
  MEDIA_TYPE_CODE       VARCHAR2(30)  ,
  MEDIA_TYPE_DESC       VARCHAR2(80)  ,
  VOLUME                VARCHAR2(150) ,
  ISSUE                 VARCHAR2(30)  ,
  ISSUE_NUMBER          NUMBER        ,
  LANGUAGE              VARCHAR2(4)   ,
  SOURCE_LANG           VARCHAR2(4)   ,
  COMMENTS              VARCHAR2(2000),
  OBJECT_VERSION_NUMBER NUMBER        ,
  ATTRIBUTE_CATEGORY    VARCHAR2(30)  ,
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
  DELETE_FLAG           VARCHAR2(1)   := 'N'
  );



 -- Declare the table type
 TYPE revision_tbl IS TABLE OF revision_rec INDEX BY BINARY_INTEGER;

/*#
 * It allows creation of document revisions.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_revision_tbl Document revisions table of type revision_tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Document Revision
 */
 PROCEDURE CREATE_REVISION
 (
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl               IN OUT NOCOPY  revision_tbl          ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );


/*#
 * It allows modification and deletion of document revisions.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_revision_tbl Document revisions table of type revision_tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Document Revision
 */
PROCEDURE MODIFY_REVISION
(
 p_api_version                  IN  NUMBER    :=  1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl               IN  OUT NOCOPY revision_tbl          ,
 p_module_type                  IN  VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );
-- Procedure to create revision copy for an associated revision
END AHL_DI_DOC_REVISION_PUB;

 

/
