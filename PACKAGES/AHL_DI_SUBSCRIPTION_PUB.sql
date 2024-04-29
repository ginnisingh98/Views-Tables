--------------------------------------------------------
--  DDL for Package AHL_DI_SUBSCRIPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_SUBSCRIPTION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPSUBS.pls 120.0 2005/05/26 01:24:38 appldev noship $ */
/*#
 * This is the public interface to create, modify and delete document subscriptions.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Document Subscription
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_DOCUMENT
 */

-- Name        : subscription_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the subscriptions

TYPE subscription_rec IS RECORD
 (
  SUBSCRIPTION_ID        NUMBER        ,
  DOCUMENT_ID            NUMBER        ,
  STATUS_CODE            VARCHAR2(30)  ,
  STATUS_DESC            VARCHAR2(80)  ,
  REQUESTED_BY_PARTY_ID  NUMBER        ,
  REQUESTED_BY_PTY_NUMBER  VARCHAR2(80)  ,
  REQUESTED_BY_PTY_NAME  VARCHAR2(301) ,
  QUANTITY               NUMBER        ,
  FREQUENCY_CODE         VARCHAR2(30)  ,
  FREQUENCY_DESC         VARCHAR2(80)  ,
  SUBSCRIBED_FRM_PARTY_ID NUMBER       ,
  SUBSCRIBED_FRM_PTY_NUMBER VARCHAR2(240) ,
  SUBSCRIBED_FRM_PTY_NAME VARCHAR2(360),
  START_DATE             DATE          ,
  END_DATE               DATE          ,
  PURCHASE_ORDER_NO      VARCHAR2(20)  ,
  SUBSCRIPTION_TYPE_CODE VARCHAR2(30)  ,
  SUBSCRIPTION_TYPE_DESC VARCHAR2(80)  ,
  MEDIA_TYPE_CODE        VARCHAR2(30)  ,
  MEDIA_TYPE_DESC        VARCHAR2(80)  ,
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
  LANGUAGE               VARCHAR2(4)   ,
  SOURCE_LANG            VARCHAR2(4)   ,
  COMMENTS               VARCHAR2(2000),
  OBJECT_VERSION_NUMBER  NUMBER        ,
  DELETE_FLAG            VARCHAR2(1)   := 'N'
  );

 TYPE subscription_tbl IS TABLE OF subscription_rec
 INDEX BY BINARY_INTEGER;

/*#
 * It allows creation of document subscriptions.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_subscription_tbl Document subscriptions table of type subscription_tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Document Subscription
 */
 PROCEDURE CREATE_SUBSCRIPTION
 (
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl           IN  OUT NOCOPY subscription_tbl      ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

/*#
 * It allows modification and deletion of document subscriptions.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_validate_only To decide whether to validate, default value FND_API.G_TRUE
 * @param p_module_type To indicate whether called 'API' or 'JSP', default value NULL
 * @param x_return_status Return status
 * @param x_msg_count Return message count
 * @param x_msg_data Return message data
 * @param p_x_subscription_tbl Document subscriptions table of type subscription_tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Document Subscription
 */
PROCEDURE MODIFY_SUBSCRIPTION
(
 p_api_version                  IN  NUMBER    := 1.0               ,
 p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only                IN  VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl           IN  OUT NOCOPY subscription_tbl      ,
 p_module_type                  IN  VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2);

END AHL_DI_SUBSCRIPTION_PUB;

 

/
