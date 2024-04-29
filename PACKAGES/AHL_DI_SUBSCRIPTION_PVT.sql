--------------------------------------------------------
--  DDL for Package AHL_DI_SUBSCRIPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_SUBSCRIPTION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSUBS.pls 115.8 2002/12/03 12:32:29 pbarman noship $  */
-- Name        : subscription_rec
-- Type        : type definition, group
-- Description : Record to hold the attributes of the subscriptions

TYPE subscription_rec IS RECORD
 (
  SUBSCRIPTION_ID        NUMBER        ,
  DOCUMENT_ID            NUMBER        ,
  STATUS_CODE            VARCHAR2(30)  ,
  REQUESTED_BY_PARTY_ID  NUMBER        ,
  QUANTITY               NUMBER        ,
  FREQUENCY_CODE         VARCHAR2(30)  ,
  SUBSCRIBED_FRM_PARTY_ID NUMBER       ,
  START_DATE             DATE          ,
  END_DATE               DATE          ,
  PURCHASE_ORDER_NO      VARCHAR2(20)  ,
  SUBSCRIPTION_TYPE_CODE VARCHAR2(30)  ,
  MEDIA_TYPE_CODE        VARCHAR2(30)  ,
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
 --Declare table type
 TYPE subscription_tbl IS TABLE OF subscription_rec
 INDEX BY BINARY_INTEGER;

-- Procedure to create subscription for an associated document
 PROCEDURE CREATE_SUBSCRIPTION
 (
 p_api_version                IN      NUMBER    := 1.0               ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN  OUT NOCOPY subscription_tbl          ,
 x_return_status                  OUT NOCOPY VARCHAR2                         ,
 x_msg_count                      OUT NOCOPY NUMBER                           ,
 x_msg_data                       OUT NOCOPY VARCHAR2);

-- Procedure to Modify subscription for an associated document
PROCEDURE MODIFY_SUBSCRIPTION
(
 p_api_version                IN      NUMBER    := 1.0               ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN  OUT NOCOPY subscription_tbl          ,
 x_return_status                  OUT NOCOPY VARCHAR2                         ,
 x_msg_count                      OUT NOCOPY NUMBER                           ,
 x_msg_data                       OUT NOCOPY VARCHAR2);

-- Procedure to Delete subscription for an associated document(This is
-- not supported in this phase)
PROCEDURE DELETE_SUBSCRIPTION
(
 p_api_version                IN     NUMBER    := 1.0               ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN OUT NOCOPY subscription_tbl          ,
 x_return_status                 OUT NOCOPY VARCHAR2                         ,
 x_msg_count                     OUT NOCOPY NUMBER                           ,
 x_msg_data                      OUT NOCOPY VARCHAR2);

END AHL_DI_SUBSCRIPTION_PVT;

 

/
