--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOC_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOC_GEN_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDAGS.pls 120.0 2005/05/25 23:56:49 appldev noship $ */
/*#
 * This is the private interface to associate and dis-associate existing documents and revisions to other CMRO objects.
 * @rep:scope private
 * @rep:product AHL
 * @rep:displayname Document Association
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_DOCUMENT
 */

TYPE association_rec IS RECORD
 (
  DOC_TITLE_ASSO_ID      NUMBER        := NULL,
  DOCUMENT_ID            NUMBER        := NULL,
  DOCUMENT_NO            VARCHAR2(80)  := NULL,
  DOC_REVISION_ID        NUMBER        := NULL,
  REVISION_NO            VARCHAR2(30)  := NULL,
  USE_LATEST_REV_FLAG    VARCHAR2(1)   := NULL,
  ASO_OBJECT_TYPE_CODE   VARCHAR2(30)  := NULL,
  ASO_OBJECT_DESC        VARCHAR2(80)  := NULL,
  ASO_OBJECT_ID          NUMBER        := NULL,
  SERIAL_NO              VARCHAR2(30)  := NULL,
  SOURCE_LANG            VARCHAR2(12)  := NULL,
  CHAPTER                VARCHAR2(30)  := NULL,
  SECTION                VARCHAR2(30)  := NULL,
  SUBJECT                VARCHAR2(240) := NULL,
  PAGE                   VARCHAR2(5)   := NULL,
  FIGURE                 VARCHAR2(30)  := NULL,
  NOTE                   VARCHAR2(2000):= NULL,
  SOURCE_REF_CODE        VARCHAR2(30)  := NULL,
  SOURCE_REF_MEAN        VARCHAR2(80)  := NULL,
  OBJECT_VERSION_NUMBER  NUMBER        := NULL,
  ATTRIBUTE_CATEGORY     VARCHAR2(30)  := NULL,
  ATTRIBUTE1             VARCHAR2(150) := NULL,
  ATTRIBUTE2             VARCHAR2(150) := NULL,
  ATTRIBUTE3             VARCHAR2(150) := NULL,
  ATTRIBUTE4             VARCHAR2(150) := NULL,
  ATTRIBUTE5             VARCHAR2(150) := NULL,
  ATTRIBUTE6             VARCHAR2(150) := NULL,
  ATTRIBUTE7             VARCHAR2(150) := NULL,
  ATTRIBUTE8             VARCHAR2(150) := NULL,
  ATTRIBUTE9             VARCHAR2(150) := NULL,
  ATTRIBUTE10            VARCHAR2(150) := NULL,
  ATTRIBUTE11            VARCHAR2(150) := NULL,
  ATTRIBUTE12            VARCHAR2(150) := NULL,
  ATTRIBUTE13            VARCHAR2(150) := NULL,
  ATTRIBUTE14            VARCHAR2(150) := NULL,
  ATTRIBUTE15            VARCHAR2(150) := NULL,
  DML_OPERATION          VARCHAR2(1)   := 'N'
  );


 TYPE association_tbl IS TABLE OF association_rec INDEX BY BINARY_INTEGER;

/*#
 * It allows association and dis-association of existing documents and revisions to other CMRO objects.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_association_tbl Document associations table of type association_tbl
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Process Document Association
 */
PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version               IN     		NUMBER    := 1.0,
 p_init_msg_list             IN     		VARCHAR2  := FND_API.G_TRUE,
 p_commit                    IN     		VARCHAR2  := FND_API.G_FALSE ,
 p_validation_level          IN     		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_validate_only             IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type               IN     		VARCHAR2 ,
 x_return_status             OUT NOCOPY		VARCHAR2,
 x_msg_count                 OUT NOCOPY		NUMBER,
 x_msg_data                  OUT NOCOPY		VARCHAR2,
 p_x_association_tbl         IN OUT NOCOPY 	association_tbl
);

END AHL_DI_ASSO_DOC_GEN_PUB;

 

/
