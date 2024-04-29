--------------------------------------------------------
--  DDL for Package AHL_DI_PRO_TYPE_ASO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_PRO_TYPE_ASO_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPTAS.pls 120.0 2005/05/26 00:58:07 appldev noship $ */
/*#
 * This is the private interface to create, modify and delete document type associations to document sub-types.
 * @rep:scope private
 * @rep:product AHL
 * @rep:displayname Document Type Association
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_DOCUMENT
 */

-- Name        : doc type association rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of document type and subtype
--               associations

TYPE doc_type_assoc_rec IS RECORD
 (
  DOCUMENT_SUB_TYPE_ID   NUMBER        ,
  DOC_TYPE_CODE          VARCHAR2(30)  ,
  DOC_TYPE_DESC          VARCHAR2(80)  ,
  DOC_SUB_TYPE_CODE      VARCHAR2(30)  ,
  DOC_SUB_TYPE_DESC      VARCHAR2(80)  ,
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
 --Declare Table Type
 TYPE doc_type_assoc_tbl IS TABLE OF doc_type_assoc_rec
 INDEX BY BINARY_INTEGER;

/*#
 * It allows creation of document type associations with document sub-types.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_doc_type_assoc_tbl Document type associations table of type doc_type_assoc_tbl
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create Document Type Association
 */
 PROCEDURE CREATE_DOC_TYPE_ASSOC
 (
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl         IN OUT NOCOPY  doc_type_assoc_tbl    ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);


/*#
 * It allows modification and deletion of document type associations with document sub-types.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_doc_type_assoc_tbl Document type associations table of type doc_type_assoc_tbl
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Modify Document Type Association
 */
PROCEDURE MODIFY_DOC_TYPE_ASSOC
(
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl         IN OUT NOCOPY doc_type_assoc_tbl      ,
 p_module_type                  IN  VARCHAR2                          ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

END AHL_DI_PRO_TYPE_ASO_PUB;

 

/
