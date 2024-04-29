--------------------------------------------------------
--  DDL for Package ENG_TYPE_CONFIGURATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_TYPE_CONFIGURATION_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGTYCONS.pls 115.0 2003/10/15 14:31:22 asjohal noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Search Framework                     |
 +---------------------------------------------------------------------------*/


 PROCEDURE create_type_config
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME			    IN     VARCHAR2,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE update_type_Config
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );


 PROCEDURE delete_type_config
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

---------------------------------------------------------


  PROCEDURE create_Primary_Attribute
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME		    IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_Primary_Attribute
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME                  IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_Primary_Attribute
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

---------------------------------------------------------


  PROCEDURE create_config_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_config_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_config_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

  PROCEDURE Check_Configuration_delete
  (
    X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
    X_CUSTOMIZATION_CODE           IN VARCHAR2,
    X_REGION_APPLICATION_ID        IN NUMBER,
    X_REGION_CODE                  IN VARCHAR2,
    X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE,
    X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
    X_ERRORCODE                    OUT NOCOPY NUMBER
  );

END ENG_TYPE_CONFIGURATION_PKG;

 

/
