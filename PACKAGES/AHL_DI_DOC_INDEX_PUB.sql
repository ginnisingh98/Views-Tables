--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_INDEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_INDEX_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDIXS.pls 120.0.12010000.2 2010/01/28 13:11:30 pekambar ship $ */
/*#
 * This is the public interface to create and modify documents and its associated suppliers and recipients.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Document
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_DOCUMENT
 */

--Define the Record Type for Document Index
TYPE doc_rec IS RECORD
 (
  DOCUMENT_ID           NUMBER        ,
  SOURCE_PARTY_ID       NUMBER        ,
  SOURCE_PARTY_NUMBER     VARCHAR2(80)  ,
  DOC_TYPE_CODE         VARCHAR2(30)  ,
  DOC_TYPE_DESC         VARCHAR2(80)  ,
  DOC_SUB_TYPE_CODE     VARCHAR2(30)  ,
  DOC_SUB_TYPE_DESC     VARCHAR2(80)  ,
  DOCUMENT_NO           VARCHAR2(30)  ,
  OPERATOR_CODE         VARCHAR2(30)  ,
  OPERATOR_NAME         VARCHAR2(80)  ,
  PRODUCT_TYPE_CODE     VARCHAR2(30)  ,
  PRODUCT_TYPE_DESC     VARCHAR2(80)  ,
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
  DELETE_FLAG           VARCHAR2(1)   := 'N',
  PROCESS_FLAG          VARCHAR2(1)   := 'Y'
  );
-- Define the Record Type for Supplier Documents
TYPE supplier_rec IS RECORD
 (
  SUPPLIER_DOCUMENT_ID    NUMBER        ,
  SUPPLIER_ID             NUMBER        ,
  SUPPLIER_NUMBER           VARCHAR2(80)  ,
  DOCUMENT_ID             NUMBER        ,
  PREFERENCE_CODE         VARCHAR2(30)  ,
  PREFERENCE_DESC         VARCHAR2(80)  ,
  OBJECT_VERSION_NUMBER   NUMBER        ,
  ATTRIBUTE_CATEGORY      VARCHAR2(30)  ,
  ATTRIBUTE1              VARCHAR2(150) ,
  ATTRIBUTE2              VARCHAR2(150) ,
  ATTRIBUTE3              VARCHAR2(150) ,
  ATTRIBUTE4              VARCHAR2(150) ,
  ATTRIBUTE5              VARCHAR2(150) ,
  ATTRIBUTE6              VARCHAR2(150) ,
  ATTRIBUTE7              VARCHAR2(150) ,
  ATTRIBUTE8              VARCHAR2(150) ,
  ATTRIBUTE9              VARCHAR2(150) ,
  ATTRIBUTE10             VARCHAR2(150) ,
  ATTRIBUTE11             VARCHAR2(150) ,
  ATTRIBUTE12             VARCHAR2(150) ,
  ATTRIBUTE13             VARCHAR2(150) ,
  ATTRIBUTE14             VARCHAR2(150) ,
  ATTRIBUTE15             VARCHAR2(150) ,
  DELETE_FLAG             VARCHAR2(1)   := 'N'   );

--Define the Record Type for Recipient Documents
TYPE recipient_rec IS RECORD
(
 RECIPIENT_DOCUMENT_ID    NUMBER        ,
 RECIPIENT_PARTY_ID       NUMBER        ,
 RECIPIENT_PARTY_NUMBER     VARCHAR2(80)  ,
 DOCUMENT_ID              NUMBER        ,
 OBJECT_VERSION_NUMBER    NUMBER        ,
 ATTRIBUTE_CATEGORY       VARCHAR2(30)  ,
 ATTRIBUTE1               VARCHAR2(150) ,
 ATTRIBUTE2               VARCHAR2(150) ,
 ATTRIBUTE3               VARCHAR2(150) ,
 ATTRIBUTE4               VARCHAR2(150) ,
 ATTRIBUTE5               VARCHAR2(150) ,
 ATTRIBUTE6               VARCHAR2(150) ,
 ATTRIBUTE7               VARCHAR2(150) ,
 ATTRIBUTE8               VARCHAR2(150) ,
 ATTRIBUTE9               VARCHAR2(150) ,
 ATTRIBUTE10              VARCHAR2(150) ,
 ATTRIBUTE11              VARCHAR2(150) ,
 ATTRIBUTE12              VARCHAR2(150) ,
 ATTRIBUTE13              VARCHAR2(150) ,
 ATTRIBUTE14              VARCHAR2(150) ,
 ATTRIBUTE15              VARCHAR2(150) ,
 DELETE_FLAG              VARCHAR2(1)   := 'N'  );

-- Defiene the Table Type for Document Indexes and its associated
-- Suppliers and Recipients
 TYPE document_tbl IS TABLE OF doc_rec INDEX BY BINARY_INTEGER;
 TYPE supplier_tbl IS TABLE OF supplier_rec INDEX BY BINARY_INTEGER;
 TYPE recipient_tbl IS TABLE OF recipient_rec INDEX BY BINARY_INTEGER;
 --This API is used to create new document index record and its associated
 -- suppliers, recipients

/*#
 * It allows creation of documents. It also allows association of suppliers and recepients.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_document_tbl Documents table of type Document_Tbl
 * @param p_x_supplier_tbl Suppliers table of type Supplier_Tbl
 * @param p_x_recipient_tbl Recipients table of type Recipient_Tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Document
 */
 PROCEDURE CREATE_DOCUMENT
 (
 p_api_version                  IN     NUMBER    := '1.0'               ,
 p_init_msg_list                IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl               IN OUT NOCOPY Document_Tbl           ,
-- p_x_doc_rev_tbl                IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Tbl ,
-- p_x_doc_rev_copy_tbl           IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Copy_Tbl,
-- p_x_subscription_tbl           IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PUB.Subscription_Tbl,
 p_x_supplier_tbl               IN OUT NOCOPY Supplier_Tbl           ,
 p_x_recipient_tbl              IN OUT NOCOPY Recipient_Tbl          ,
 p_module_type                  IN     VARCHAR2                       ,
 x_return_status                   OUT NOCOPY VARCHAR2                         ,
 x_msg_count                       OUT NOCOPY NUMBER                           ,
 x_msg_data                        OUT NOCOPY VARCHAR2
 );
-- This is used to Update any document index record as well suppliers, recipients
-- subscriptions and revisions. In this phase we are supporting remove any supplier
-- or recipient record relates to document index

/*#
 * It allows modifications of document details. It also allows modification and deletion of associated suppliers and recepients.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_document_tbl Documents table of type Document_Tbl
 * @param p_x_supplier_tbl Suppliers table of type Supplier_Tbl
 * @param p_x_recipient_tbl Recipients table of type Recipient_Tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Document
 */
 PROCEDURE MODIFY_DOCUMENT
(
 p_api_version                  IN     NUMBER    := '1.0'               ,
 p_init_msg_list                IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl               IN OUT NOCOPY document_tbl           ,
-- p_x_doc_rev_tbl                IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Tbl ,
-- p_x_doc_rev_copy_tbl           IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Copy_Tbl,
-- p_x_subscription_tbl           IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PUB.Subscription_Tbl,
 p_x_supplier_tbl               IN OUT NOCOPY Supplier_Tbl           ,
 p_x_recipient_tbl              IN OUT NOCOPY Recipient_Tbl          ,
 p_module_type                  IN     VARCHAR2                        ,
 x_return_status                   OUT NOCOPY VARCHAR2                         ,
 x_msg_count                       OUT NOCOPY NUMBER                           ,
 x_msg_data                        OUT NOCOPY VARCHAR2 );

END AHL_DI_DOC_INDEX_PUB;

/
